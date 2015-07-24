function [ best_atk_targets ] = attack_strat_fun( impact_matrix, cost_of_attack, prob_success_atk )
%ATTACK_STRAT_FUN Determins and Attack strategy
%   Given an impact matrix which is DEFENDERxTARGETS , probablity of
%   successful attack given it was attacked, and a cost of an attack, the
%   optimal strategy is selected



n_defenders=size(impact_matrix,1);
n_targets=size(impact_matrix,2);
adjusted_impact_matrix=impact_matrix.*prob_success_atk;

%Solve combination problem, as exhaustive search
psize=0;
for k=1:n_defenders
    psize=psize+size(nchoosek(1:n_defenders,k),1);
end

defender_choice=cell(psize,1);
defender_choice_val=zeros(psize,1);
i=1;
for k=1:n_defenders
    C=nchoosek(1:n_defenders,k);
    for j=1:length(C)
        try
            idx=C(j,:);
        catch
            idx=C(j);
        end
        defender_choice{i}=idx;
        
        tmp_adj_imp=adjusted_impact_matrix(idx,:);
        target_choice=zeros(n_targets,1);
        %take all column whose sum is larger than zero
        sumval=sum(tmp_adj_imp,1)-cost_of_attack';
        target_choice(sumval>0)=1;
        utility=sum(sumval(target_choice==1));
        defender_choice_val(i)=utility;
        i=i+1;
    end
end

[~,idx]=max(defender_choice_val);
idx=defender_choice{idx};
tmp_adj_imp=adjusted_impact_matrix(idx,:);
target_choice=zeros(n_targets,1);
%take all column whose sum is larger than zero
sumval=sum(tmp_adj_imp,1);
target_choice(sumval>0)=1;
best_atk_targets=target_choice;



end

