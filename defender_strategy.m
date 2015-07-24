function [ protected_targets,defense_cost, risk_mitigated ] = defender_strategy( impact_matrix,target_atk_prob,target_defense_cost,ownership,max_defense_cost,collaboration_matrix )
%DEFENDER_STRATEGY Summary of this function goes here
%   Detailed explanation goes here

nTargets=size(impact_matrix,1);
nOwners=size(impact_matrix,2);
if nOwners < max(ownership)
    %It may happen that under uniform distribution, some owners might not
    %exist but since indexing is 1-n with no gaps, need to find the culprit
    %and squeeze it
    for i=1:max(ownership)
        if isempty(ownership(ownership==i))
            ownership(ownership>i)=ownership(ownership>i)-1; %Shift index
        end
    end

end

%Find Feasible Collaborations
%set of collaborations
%collaboration_matrix
targets_per_owner_cost=zeros(nTargets,nOwners);
targets_impact=zeros(nTargets,1);
target_is_collab=zeros(nTargets,1);
target_allowed_collab=zeros(nTargets,nOwners);
for i=1:nTargets
    impact_vector=impact_matrix(i,:).*target_atk_prob(i);
    target_owner=ownership(i);
    if impact_vector(target_owner)>0
        impact_vector(target_owner)=0;
    end
    owner_idx=zeros(nOwners,1)';
    owner_idx(target_owner)=1;
    allowed_collab=collaboration_matrix(target_owner,:);
    %Remove positive impact collaborators
    allowed_collab(impact_vector(allowed_collab==1)>0)=0;
    allowed_collab(target_owner)=0;
    target_allowed_collab(i,:)=allowed_collab;
    total_impact=sum(impact_vector(allowed_collab==1 | owner_idx==1));
    per_owner_cost=zeros(nOwners,1);
    per_owner_cost(allowed_collab==1 | owner_idx==1)=impact_vector(allowed_collab==1 | owner_idx==1)./total_impact*target_defense_cost(i);
    if total_impact==0
        per_owner_cost=zeros(nOwners,1);
        per_owner_cost(target_owner)=target_defense_cost(i);
    end
    targets_per_owner_cost(i,:)=per_owner_cost;
    targets_impact(i)=total_impact;
    if sum(allowed_collab) > 0
        target_is_collab(i)=1;
    end
end

%Optimization Problem 0-1 Knapsack

%Min f*DEFENDED , awakward signage but impact is negative for loss, the
%more negative here, the more loss mitigated
f=targets_impact+target_defense_cost;

%A*DEFENDED<=b , constraint on cost
A=targets_per_owner_cost';
b=ones(nOwners,1)*max_defense_cost;

%Aeq*DEFENDED=beq , use to requre joint defenses
%{
if sum(target_is_collab) > 0
Aeq=zeros(sum(target_is_collab),nTargets);
beq=zeros(sum(target_is_collab),1);
k=0;
for i=1:nTargets
    if(target_is_collab(i) ~= 1)
        continue;
    end
    k=k+1;
    num_collab=sum(target_allowed_collab(i,:));
    row=zeros(nTargets,1);
    row(target_allowed_collab(i,:)==1)=1;
    row(ownership(i))=-1*num_collab;
    Aeq(k,:)=row;
end
else
    Aeq=[];
    beq=[];
end
%}
Aeq=[];
beq=[];

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if isOctave
	nr_f = rows(f);
	nr_A = rows(A);
	ctype = [(repmat ('U', nr_A, 1))];
	vartype = [(repmat ('I', nr_f, 1))];
	sense=1; %1=min , -1=max
	param.lpsolver=1; %2=interior 1=simplex
	param.dual=2;
	param.presol=0;
	param.msglev=0;
	%Binary so
	lb=zeros(nr_f,1);
	ub=ones(nr_f,1);
	[x(1:nr_f, 1) fval(1, 1)] = glpk (f, A, b, lb,ub, ctype, vartype, sense, param);
	protected_targets=x;
else
    try
	[protected_targets,~,eflag]=bintprog(f,A,b);
    catch e
        protected_targets=zeros(nTargets,1);
        disp('Failed BINTPROG');
        eflag=1;
    end
	if eflag~=1
	   % keyboard
	end
end
defense_cost=sum(targets_per_owner_cost(protected_targets==1,:));
risk_mitigated=sum(targets_impact(protected_targets==1));

end

