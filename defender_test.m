

%Load run 4 data

%run4_data
noise_attacker_vals=run4_input.v1;
noise_defender_vals=run4_input.v2;
nOwner_vals=run4_input.v3;
mc_num_vals=run4_input.v4;

output=run4_data{2,2,2,1};
tmp=output.attack_targets{1};
nAssets=size(tmp,2);

%Calc attack prob. for attacker taking 4 targets
nTargets=4;
nsubMc=length(output.attack_targets);
attack_targets=zeros(nsubMc,nAssets);
for i=1:nsubMc
    tmp1=output.attack_targets{i};
    tmp2=tmp1(nTargets,:);
    attack_targets(i,:)=tmp2;
end
attack_freq=sum(attack_targets,1);
target_atk_prob=squeeze(attack_freq/nsubMc);
ownership=output.ownership;
impact_matrix=output.defender_impact_matrix;
target_defense_cost=ones(nAssets,1);
max_defense_cost=4;
%Collab is ownerxowner matrix
no_collaboration_matrix=zeros(size(impact_matrix,2),size(impact_matrix,2));
full_collaboration_matrix=ones(size(impact_matrix,2),size(impact_matrix,2));

[ protected_targets,defense_cost, risk_mitigated ] = defender_strategy( impact_matrix,target_atk_prob,target_defense_cost,ownership,max_defense_cost,full_collaboration_matrix );

