
%Syntetic Data
n_defenders=8;
n_targets=1000;
impact_matrix=randi([-200 100],n_defenders,n_targets);
prob_success_atk=rand(n_defenders,n_targets)*0.1;
cost_of_defense=1+19*rand(n_targets,1);
cost_of_attack=1+9*rand(n_targets,1);
owners=zeros(n_targets,1);

%Condition: Owners should always see a negative impact
for i=1:n_targets
    value_vector=impact_matrix(:,i);
    owner_list=1:n_defenders;
    owner_list(value_vector>0)=[];
    if isempty(owner_list)
        idx=randi([1 n_defenders]);
        owner_list=1:n_defenders;
    else
        idx=randi([1 length(owner_list)]);
    end
    owners(i)=owner_list(idx);
end

defended=zeros(n_targets,1);

%Next, play multi-round game until equilibrum reached
changed=1;
last_sum=0;
while (changed==1)
   tmp_impact_matrix=impact_matrix;
   tmp_impact_matrix(:,defended==1)=0;
   targets=attack_strat_fun(tmp_impact_matrix,cost_of_attack,prob_success_atk);
   [new_defended,~]=defense_strat_fun(impact_matrix,cost_of_defense,prob_success_atk,owners, targets);
   defended=defended+new_defended;
   defended(defended>0)=1;
   new_sum=sum(defended);
   if new_sum == last_sum
       changed=0;
   else
       last_sum=new_sum;
   end
end

defendse_cost=sum(cost_of_defense(defended==1));

