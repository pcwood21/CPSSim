%Prototyping File, Not used in practice

n_defenders=8;
n_targets=1000;
impact_matrix=randi([-200 100],n_defenders,n_targets);
prob_success_atk=rand(n_defenders,n_targets);
cost_of_defense=1+19*rand(n_targets,1);
cost_of_attack=1+9*rand(n_targets,1);
owners=zeros(n_targets,1);

%Condition: Owners should always see a negative impact
for i=1:n_targets
    value_vector=impact_matrix(:,i);
    owner_list=1:n_defenders;
    owner_list(value_vector>0)=[];
    idx=randi([1 length(owner_list)]);
    owners(i)=owner_list(idx);
end

%Went into Function
adjusted_impact_matrix=impact_matrix.*prob_success_atk;

targets=attack_strat_fun(impact_matrix,cost_of_attack,prob_success_atk);

impct=adjusted_impact_matrix;
impct(:,targets==0)=0;
defender_values=zeros(n_targets,1);
for i=1:n_targets
    defender_values(i)=impct(owners(i),i);
end
defender_values=defender_values.*-1;
defender_values=defender_values-cost_of_defense;
defended=defender_values>0;
defense_cost=sum(cost_of_defense(defended==1));

