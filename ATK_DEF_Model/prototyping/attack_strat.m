%Prototyping File, Not used in practice

n_defenders=8;
n_targets=1000;
impact_matrix=randi([-200 100],n_defenders,n_targets);
prob_success_atk=rand(n_defenders,n_targets);
cost_of_attack=1+9*rand(n_targets,1);

value_matrix=impact_matrix.*prob_success_atk;
value_matrix(value_matrix<0)=0;

adjusted_impact_matrix=impact_matrix.*prob_success_atk;

%Solve combination problem, as exhaustive search
psize=0;
for k=1:n_defenders
    psize=psize+size(nchoosek(1:n_defenders,k),1);
end

defender_choice=cell(psize,1);
defender_choice_val=zeros(psize,1);
itime=cputime;
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
        sumval=sum(tmp_adj_imp,1);
        target_choice(sumval>0)=1;
        utility=sum(sumval(target_choice==1));
        defender_choice_val(i)=utility;
        i=i+1;
    end
end
otime=cputime-itime;

[~,idx]=max(defender_choice_val);
best_atk_vect=defender_choice{idx};
otime

