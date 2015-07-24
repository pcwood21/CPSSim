function [ defended,defense_cost ] = defense_strat_fun( impact_matrix,cost_of_defense,prob_success_atk,owners, targets )
%DEFENSE_STRAT_FUN Determines Defense Strategy
%   Given a set of targets, and supporting parameters, a decision is made
%   whether or not to protect an asset based on the attack likelihood

%n_defenders=size(impact_matrix,1);
n_targets=size(impact_matrix,2);
adjusted_impact_matrix=impact_matrix.*prob_success_atk;

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

end

