function output = run11_deception(nOwners,mc_num)

%create_run(11,'run11_deception',[2 4 6 12],[1:1:48]);

%Import the NG model as edges, capacity, cost, and loss ground truth
[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[total_cost,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;
nEdges=length(edges);

rand_own=randi([1,nOwners],[nEdges,1]);
noise=0.1;

tlpp=add_noise_lpp(linprog_params,noise);
[~,tflows]=optimize_cost(tlpp);
tlpp.x0=tflows;
linprog_params=tlpp;

%Calculate baseline target values
%truth_impact is edge by owner impact of attack (negative is a loss) for a 100% capacity reduction in each edge
truth_impact=create_impact_matrix(linprog_params,rand_own,1);

%Limit the number of targets the adversary selects
nTargets=5;

%Calculate the attacker's strategy on the base model
[~,~,atk_true_value]=attacker_strategy(truth_impact,nTargets);


attack_values_array=zeros(nEdges,1);
attack_false_values_array=zeros(nEdges,1);
for i=1:nEdges
    %copy the model
    tlpp=linprog_params;
    %Apply a capacity perturbation (ub)
    tlpp.ub(i)=tlpp.ub(i)*1.5; %increase the upper bound (capacity) of edge i
    %Recalculate the impact matrix with the perturbation (deceptive)
    decept_impact=create_impact_matrix(tlpp,rand_own,1);
    %Calculate the new attacker's strategy
    [atk_owners,atk_targets,atk_false_value]=attacker_strategy(decept_impact,nTargets);
    %Find the value of the attack based upon ground truth
    atk_values=truth_impact(:,atk_owners);
    attack_values_array(i)=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
    %False value is deceptive, expected return
    attack_false_values_array(i)=atk_false_value;
end

deceptive_impact=atk_true_value-attack_values_array;

%C = sort(A,'descend')
deceptive_impact=sort(deceptive_impact,1,'ascend');
sum_impact=zeros(nEdges,1);
for i=1:nEdges
    sum_impact(i)=sum(deceptive_impact(1:i));
end

output.sum_impact=sum_impact;
output.deceptive_impact=deceptive_impact;
output.attack_values_array=attack_values_array;
output.attack_false_values_array=attack_false_values_array;
output.atk_true_value=atk_true_value;
output.impact_truth=truth_impact;
output.ownership=rand_own;
output.linprog_params=linprog_params;
output.nOwners=nOwners;
output.mc_num=mc_num;



end