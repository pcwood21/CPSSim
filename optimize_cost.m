function [ cost,flows ] = optimize_cost( linprog_params )
%SINGLE_ACTOR_COST_OPTIMIZE Performs optimization problem given inputs of
%capacity, cost, loss, and edges
%   All of the inputs, except edges, are per-edge vectors in the order of
%   the input edges

f=linprog_params.f;
A=linprog_params.A;
b=linprog_params.b';
Aeq=linprog_params.Aeq;
beq=linprog_params.beq;
lb=linprog_params.lb;
ub=linprog_params.ub;

try
    x0=linprog_params.x0;
catch  %#ok<CTCH>
    x0=[];
end

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if isOctave
nr_f = rows(f);
nr_A = rows (A);
nr_Aeq = rows (Aeq);
ctype = [(repmat ('U', nr_A, 1));
             (repmat ('S', nr_Aeq, 1))];
vartype = [(repmat ('C', nr_f, 1))];
sense=1; %1=min , -1=max
param.lpsolver=1; %2=interior 1=simplex
param.dual=2;
param.presol=0;
param.msglev=0;
%param.tolobj=1e-6; %TolFun
[x(1:nr_f, 1) fval(1, 1)] = glpk (f, [A; Aeq], [b; beq], lb, ub, ctype, vartype, sense, param);
%flows = glpk 
%[flows,~]=linprog(f,A,b,Aeq,beq,lb,ub);
flows=x;
else
options=optimset('Display', 'off','TolFun',1e-6,'TolX',1e-2);
[flows,~]=linprog(f,A,b,Aeq,beq,lb,ub,x0,options);
end

cost=sum(flows.*f);

end

