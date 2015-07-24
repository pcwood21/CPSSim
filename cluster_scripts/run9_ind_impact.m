function output = run9_ind_impact(noise,nOwners,mc_num)

%create_run(9,'run9_ind_impact',[0:0.05:0.5],[2 4 6 12],[1:1:100]);

%Import the NG model as edges, capacity, cost, and loss ground truth
[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[total_cost,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;
nEdges=length(edges);


rand_own=randi([1,nOwners],[nEdges,1]);
ownership=rand_own;

truth_impact=create_impact_matrix(linprog_params,rand_own,1);
owner_impact=cell();

for i=1:nOwners
    tlpp=add_noise_lpp(linprog_params,noise);
    tlpp.f(ownership==i)=linprog_params.f(ownership==i);
    tlpp.ub(ownership==i)=linprog_params.ub(ownership==i);
    linprog_params_cell{i}=tlpp;
    timp_random=create_impact_matrix(tlpp,rand_own,1);
    owner_impact{i}=timp_random;
    
    nTargetMax=5;

    attack_values_array=zeros(nTargetMax,1);
    attack_false_values_array=zeros(nTargetMax,1);
    attack_targets_array=zeros(nTargetMax,nEdges);
    attack_owners_array=zeros(nTargetMax,nOwners);
    local_impact=zeros(nTargetMax,1);

    for j=1:nTargetMax
        [atk_owners,atk_targets,atk_false_value]=attacker_strategy(timp_random,j);
        atk_values=truth_impact(:,atk_owners);
        attack_values_array(j)=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
        atk_local_values=timp_random(:,atk_owners);
        attack_values_array(j)=sum(sum(atk_local_values(atk_targets,1:size(atk_local_values,2))));
        attack_false_values_array(j)=atk_false_value;
        row=zeros(1,nEdges);
        row(atk_targets)=1;
        attack_targets_array(j,:)=row;
        row=zeros(1,nOwners);
        row(atk_owners)=1;
        attack_owners_array(j,:)=row;
        local_impact(j)=sum(timp_random(attack_targets_array(j,:)==1,i));
    end
    
    
    attack_values_array_cell{i}=attack_values_array;
    attack_false_values_array_cell{i}=attack_false_values_array;
    attack_targets_array_cell{i}=attack_targets_array;
    attack_owners_array_cell{i}=attack_owners_array;
    local_impact_cell{i}=local_impact;
    

end

[ind_profits] = ind_assign_profits(ownership,linprog_params_cell,linprog_params);
[orig_profits] = assign_profits(ownership,linprog_params);


%Difference in best attack's impact and actual attack's impact
nTargetMax=5;
mismatch_value=zeros(nOwners,nTargetMax);
actual_atk_impact=zeros(nOwners,nTargetMax);
impact_diff=zeros(nOwners,nTargetMax);
for j=1:nTargetMax
[~,atk_targets,~]=attacker_strategy(truth_impact,j);
row=zeros(1,nEdges);
row(atk_targets)=1;
atk_targets=row;

for i=1:nOwners
    actual_atk_impact(i,j)=sum(truth_impact(atk_targets==1,i));
    expected_targets=attack_targets_array_cell{i};
    expected_targets=expected_targets(j,:);
    expected_atk_impact=local_impact_cell{i};
    mismatch_value(i,j)=sum(truth_impact(xor(atk_targets==1,expected_targets==1),i));
    impact_diff(i,j)=actual_atk_impact(i,j)-expected_atk_impact(j);
end

end

output.mismatch_value=mismatch_value;
output.actual_atk_impact=actual_atk_impact;
output.impact_diff=impact_diff;
output.ind_profits=ind_profits;
output.orig_profits=orig_profits;
output.attack_values_array_cell=attack_values_array_cell;
output.attack_false_values_array_cell=attack_false_values_array_cell;
output.attack_targets_array_cell=attack_targets_array_cell;
output.attack_owners_array_cell=attack_owners_array_cell;
output.local_impact_cell=local_impact_cell;
output.owner_impact=owner_impact;
output.ownership=rand_own;
output.noise=noise;
output.nOwners=nOwners;
output.truth_impact=truth_impact;
output.mc_num=mc_num;



end