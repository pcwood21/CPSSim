function output = run3_impact_matrix_calc(noise,nOwners,mc_num)

%Import the NG model as edges, capacity, cost, and loss ground truth
[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[total_cost,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;
nEdges=length(edges);

rand_own=randi([1,nOwners],[nEdges,1]);

tlpp=add_noise_lpp(linprog_params,noise);
[~,tflows]=optimize_cost(tlpp);
tlpp.x0=tflows;
timp_random=create_impact_matrix(tlpp,rand_own,1);
truth_impact=create_impact_matrix(linprog_params,rand_own,1);

nTargetMax=20;

attack_values_array=zeros(nTargetMax,1);
attack_false_values_array=zeros(nTargetMax,1);
attack_targets_array=zeros(nTargetMax,nEdges);
attack_owners_array=zeros(nTargetMax,nOwners);

for i=1:nTargetMax
	[atk_owners,atk_targets,atk_false_value]=attacker_strategy(timp_random,i);
	atk_values=truth_impact(:,atk_owners);
	attack_values_array(i)=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
	attack_false_values_array(i)=atk_false_value;
	row=zeros(1,nEdges);
	row(atk_targets)=1;
	attack_targets_array(i,:)=row;
	row=zeros(1,nOwners);
	row(atk_owners)=1;
	attack_owners_array(i,:)=row;
end

output.impact_matrix=timp_random;
output.impact_truth=truth_impact;
output.ownership=rand_own;
output.attack_targets=attack_targets_array;
output.attack_value=attack_values_array;
output.attack_owners=attack_owners_array;
output.attack_false_value=attack_false_values_array;
output.noise=noise;
output.nOwners=nOwners;
output.mc_num=mc_num;



end