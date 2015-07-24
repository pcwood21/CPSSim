function output = run12_deception(nOwners, mc_num, perturb_val)

%create_run(12,'run12_deception',[2 4 6 12],[1:1:48],[0:0.1:1]);

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


tlpp=linprog_params;
for i=1:nEdges
    %Apply a capacity perturbation (ub)
    tlpp.ub(i)=tlpp.ub(i)*(1 + perturb_val); %increase the upper bound (capacity) of edge i
end
%Recalculate the impact matrix with the perturbation (deceptive)
decept_impact=create_impact_matrix(tlpp,rand_own,1);
%Calculate the new attacker's strategy
[atk_owners,atk_targets,atk_false_value]=attacker_strategy(decept_impact,nTargets);
%Find the value of the attack based upon ground truth
atk_values=truth_impact(:,atk_owners);
attack_values_array=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
%False value is deceptive, expected return
attack_false_values_array=atk_false_value;


deceptive_impact=atk_true_value-attack_values_array;

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
