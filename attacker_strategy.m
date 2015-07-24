function [ owners,targets, profit ] = attacker_strategy( impact_matrix, varargin )
%ATTACKER_STRATEGY Summary of this function goes here
%   Detailed explanation goes here

nTargets=size(impact_matrix,1);
nOwners=size(impact_matrix,2);
target_prob_success=ones(nTargets,1);
target_atk_cost=ones(nTargets,1);
cost_limit=4;

if nargin > 1
	cost_limit=varargin{1};
end

psize=0;
for k=1:nOwners
    psize=psize+size(nchoosek(1:nOwners,k),1);
end

owner_choice=cell(psize,1);
target_choice=cell(psize,1);
target_reward=zeros(psize,1);
i=1;
for k=1:nOwners-1
    C=nchoosek(1:nOwners,k);
    for j=1:length(C)
        try
            idx=C(j,:);
        catch
            idx=C(j);
        end
        owner_choice{i}=idx;
        tmp_impact=impact_matrix(:,idx);
        target_value=sum(tmp_impact,2).*target_prob_success;
        target_value=target_value-target_atk_cost;
        %Could implement MILP here
        f=-1*target_value;
        %intcon=1:nTargets;
        A=target_atk_cost';
        b=cost_limit;
        %lb=zeros(nTargets,1);
        %ub=ones(nTargets,1);
        options=optimset('Display', 'off');
        %[target_choice{i},target_reward(i)]=bintprog(f,A,b,[],[],[],options);
        %Instead of bintprog, just select top cost_limit targets
        [tmp,tidx]=sort(target_value,1,'descend');
        target_choice{i}=tidx(1:cost_limit);
        target_reward(i)=sum(tmp(1:cost_limit));
        i=i+1;
    end
end

[profit,idx]=max(target_reward);
targets=target_choice{idx};
owners=owner_choice{idx};

end

