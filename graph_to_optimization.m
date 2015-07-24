function [ output ] = graph_to_optimization( edges,capacity,cost,loss,fixed_flows )
%SINGLE_ACTOR_COST_OPTIMIZE Performs optimization problem given inputs of
%capacity, cost, loss, and edges
%   All of the inputs, except edges, are per-edge vectors in the order of
%   the input edges

nEdges=size(edges,1);

%Identify Nodes
nodes=unique(edges(:,2));
nNodes=length(nodes);


%Need to setup node-summation rules
opt_thruput=1-loss;
Aeq=zeros(nNodes,nEdges);
for i=1:nNodes
    row=zeros(1,nEdges);
    for k=1:nEdges
        if edges(k,1)==i %Have an output from the node
            row(k)=-1/opt_thruput(k);
        elseif edges(k,2)==i %Have an input to the node
            row(k)=1;
        end
    end
    Aeq(i,:)=row;
end
beq=zeros(nNodes,1);
%Now remove nodes which are the entry/exit points in the graph
remove=[];
for i=1:nNodes
    urow=unique(Aeq(i,:));
    urow(urow==0)=[];
    if length(urow) < 2
        remove(end+1)=i;
    end
end
Aeq(remove,:)=[];
beq(remove,:)=[];

%Now Aeq, beq act as the summation restriction on the nodes

%Any incoming "fixed flows" should be setup in the beq restriction
for k=1:size(fixed_flows,1)
    row=zeros(1,nEdges);
    row(fixed_flows(k,1))=1;
    Aeq(end+1,:)=row;
    beq(end+1)=fixed_flows(k,2);
end


%Now mapping unidirectional flow restriction
%Note: in a properly setup system, this will not be a problem, however, it
%does prevent system-waste to promote profit
A=[];
b=[];
for i=1:nEdges
    for k=1:nEdges
        %If two edges link two nodes in opposite flows
        if i ~= k && edges(i,1)==edges(k,2) && edges(i,2)==edges(k,1)
            row=zeros(1,nEdges);
            row(i)=1;
            row(k)=1;
            A(end+1,:)=row;
            b(end+1)=max(capacity(i),capacity(k));
        end
    end
end

%limit to positive flows
lb=zeros(nEdges,1);
%upper bound is capacity
ub=capacity;
%Optimizing cost (minimize)
f=cost;

output.f=f;
output.A=A;
output.b=b;
output.Aeq=Aeq;
output.beq=beq;
output.lb=lb;
output.ub=ub;


end

