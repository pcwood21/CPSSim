function output = run6_defender_analysis(noisea,noised,nOwners,mc_num)

%Import the NG model as edges, capacity, cost, and loss ground truth
[ edges,capacity,cost,loss,~ ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[~,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;
nEdges=length(edges);

rand_own=randi([1,nOwners],[nEdges,1]);

truth_impact=create_impact_matrix(linprog_params,rand_own,1);

defender_lpp=add_noise_lpp(linprog_params,noised);
[~,tflows]=optimize_cost(defender_lpp);
defender_lpp.x0=tflows;
defender_impact_matrix=create_impact_matrix(defender_lpp,rand_own,1);

nAtkMc=30;
attacker_impact_matrix=cell(nAtkMc,1);
attack_targets_cell=cell(nAtkMc,1);
attack_values_cell=cell(nAtkMc,1);
attack_owners_cell=cell(nAtkMc,1);
attack_false_values_cell=cell(nAtkMc,1);
for i=1:nAtkMc
    attacker_lpp=add_noise_lpp(defender_lpp,noisea);
    [~,tflows]=optimize_cost(attacker_lpp);
    attacker_lpp.x0=tflows;
    timp_random=create_impact_matrix(attacker_lpp,rand_own,1);
    nTargetMax=10;
    
    attack_values_array=zeros(nTargetMax,1);
    attack_false_values_array=zeros(nTargetMax,1);
    attack_targets_array=zeros(nTargetMax,nEdges);
    attack_owners_array=zeros(nTargetMax,nOwners);
    
    for k=1:nTargetMax
        [atk_owners,atk_targets,atk_false_value]=attacker_strategy(timp_random,k);
        atk_values=truth_impact(:,atk_owners);
        attack_values_array(k)=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
        attack_false_values_array(k)=atk_false_value;
        row=zeros(1,nEdges);
        row(atk_targets)=1;
        attack_targets_array(k,:)=row;
        row=zeros(1,nOwners);
        row(atk_owners)=1;
        attack_owners_array(k,:)=row;
    end
    
    attacker_impact_matrix{i}=timp_random;
    attack_targets_cell{i}=attack_targets_array;
    attack_values_cell{i}=attack_values_array;
    attack_owners_cell{i}=attack_owners_array;
    attack_false_values_cell{i}=attack_false_values_array;
end


nsubMc=nAtkMc;
nAssets=nEdges;
total_max_defense_cost=12;
max_defense_cost=total_max_defense_cost/nOwners;

risk_mitigated_array=zeros(nTargetMax,nTargetMax);
risk_mitigated_array_c=zeros(nTargetMax,nTargetMax);
protection_cost_array=zeros(nTargetMax,nTargetMax);
protection_cost_array_c=zeros(nTargetMax,nTargetMax);

for i=1:nTargetMax
	for j=1:nTargetMax

attack_targets=zeros(nsubMc,nAssets);
for m=1:nsubMc
	tmp1=attack_targets_cell{m};
	tmp2=tmp1(j,:);
	attack_targets(m,:)=tmp2;
end
attack_freq=sum(attack_targets,1);
target_atk_prob=squeeze(attack_freq/nsubMc);
ownership=rand_own;
impact_matrix=defender_impact_matrix;
target_defense_cost=ones(nAssets,1);
%truth_impact=truth_impact;
tmp=truth_impact;
tmp(tmp>0)=0;

no_collaboration_matrix=zeros(size(impact_matrix,2),size(impact_matrix,2));
[ protected_targets ,defense_cost, ~ ] = defender_strategy( impact_matrix,target_atk_prob,target_defense_cost,ownership,max_defense_cost,no_collaboration_matrix );
protection_cost_array(i,j)=sum(defense_cost);
risk_mitigated=sum(sum(tmp(protected_targets==1,:)));
risk_mitigated_array(i,j)=risk_mitigated;

full_collaboration_matrix=ones(size(impact_matrix,2),size(impact_matrix,2));
[ protected_targets ,defense_cost, ~ ] = defender_strategy( impact_matrix,target_atk_prob,target_defense_cost,ownership,max_defense_cost,full_collaboration_matrix );
protection_cost_array_c(i,j)=sum(defense_cost);
risk_mitigated=sum(sum(tmp(protected_targets==1,:)));
risk_mitigated_array_c(i,j)=risk_mitigated;

end
end



output.defender_impact_matrix=defender_impact_matrix;
output.attacker_impact_matrix=attacker_impact_matrix;
output.impact_truth=truth_impact;
output.ownership=rand_own;
output.attack_targets=attack_targets_cell;
output.attack_value=attack_values_cell;
output.attack_owners=attack_owners_cell;
output.attack_false_value=attack_false_values_cell;
output.noisea=noisea;
output.noised=noised;
output.nOwners=nOwners;
output.mc_num=mc_num;

output.risk_mitigated_array=risk_mitigated_array;
output.risk_mitigated_array_c=risk_mitigated_array_c;
output.protection_cost_array=protection_cost_array;
output.protection_cost_array_c=protection_cost_array_c;



end