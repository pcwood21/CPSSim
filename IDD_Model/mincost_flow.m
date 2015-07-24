function [output,oflows]=mincost_flow(attackEdge,attackNode,attackAmount,plotData,gaselec,inflows,varargin)

%Import the defined graph
gas_elec_combi;

loadnode=[];
if nargin == 8
	loadnode=varargin{1};
    newcap=varargin{2};
end

new_opt_cost=[];
if nargin == 7
    new_opt_cost=varargin{1};
end

if nargin == 9
    loadnode=varargin{1};
    newcap=varargin{2};
    new_opt_cost=varargin{3};
end

%Objective Function
%Minimize dollar cost of generation:
%sum(c_cost.*c_flow);

%Subject To:
%c_flow <= c_capacity

%Find Edges
[r,c] = find(c_capacity);
edges=[r,c];
%If an attacked edge is defined, then reduce its capacity by the attack amount
if ~isempty(attackEdge)
    c_capacity(attackEdge(1),attackEdge(2))=c_capacity(attackEdge(1),attackEdge(2))*attackAmount;
    if c_capacity(attackEdge(1),attackEdge(2)) < 0
        c_capacity(attackEdge(1),attackEdge(2))=0;
    end
    c_capacity(attackEdge(2),attackEdge(1))=c_capacity(attackEdge(2),attackEdge(1))*attackAmount;
    if c_capacity(attackEdge(2),attackEdge(1)) < 0
        c_capacity(attackEdge(2),attackEdge(1))=0;
    end
end

%If a node is attacked , then reduce the capacity of all of its connected edges by attack amount
if ~isempty(attackNode)
    c_capacity(attackNode,:)=c_capacity(attackNode,:)*attackAmount;
    tmp=c_capacity(attackNode,:);
    tmp(tmp<0)=0;
    c_capacity(attackNode,:)=tmp;
    c_capacity(:,attackNode)=c_capacity(:,attackNode)*attackAmount;
    tmp=c_capacity(:,attackNode);
    tmp(tmp<0)=0;
    c_capacity(:,attackNode)=tmp;
end

%Each edge is now a variable in the optimization problem
nVar=size(edges,1);
opt_capacity=zeros(nVar,1);
opt_cost=zeros(nVar,1);
opt_loss=zeros(nVar,1);
opt_demand=zeros(nVar,1);
%g and e are gas and electric
mapped_g_demand=zeros(nVar,1);
mapped_e_demand=zeros(nVar,1);
mapped_is_gas=zeros(nVar,1);
mapped_is_elec=zeros(nVar,1);
mapped_is_gen=zeros(nVar,1);
opt_supply=zeros(nVar,1);
for i=1:nVar
    opt_capacity(i)=c_capacity(edges(i,1),edges(i,2));
    opt_cost(i)=c_cost(edges(i,1),edges(i,2));
    opt_loss(i)=c_loss(edges(i,1),edges(i,2));
    opt_demand(i)=c_demand(edges(i,2));
    opt_supply(i)=c_supply(edges(i,1));
    
    mapped_g_demand(i)=g_demand(edges(i,2));
    mapped_e_demand(i)=e_demand(edges(i,2));
    
    mapped_is_elec(i)=(sum(elec_capacity(edges(i,1),:))>0);
    mapped_is_gas(i)=(sum(gas_capacity(edges(i,1),:))>0);
    %if electric out and gas in
    if sum(elec_capacity(edges(i,2),:))>0 && sum(gas_capacity(:,edges(i,2)))>0
        mapped_is_gen(i)=1;
    end
end

if ~isempty(new_opt_cost)
opt_cost=new_opt_cost;
end

lb=zeros(nVar,1);
if ~isempty(loadnode)
    for i=1:length(loadnode)
    if (newcap(i)<0)
        newcap(i)=0;
    end
    opt_capacity(loadnode(i))=newcap(i);
    lb(loadnode(i))=newcap(i);
    end
end

%At this point, the optimization problem is reduced to edges only from the graph input

%opt_cost(opt_cost<0)=opt_cost(opt_cost<0)*10;

opt_thruput=1-opt_loss;

%Construct node summation constraint
Aeq=zeros(nNodes,nVar);
for i=1:nNodes
    row=zeros(1,nVar);
    for k=1:nVar
        %If the source is this node, then allow it to go out
        if edges(k,1) == i
            row(k)=-1/opt_thruput(k);
            %It is the destination
        elseif edges(k,2) == i
            row(k)=1;
        end
    end
    Aeq(i,:)=row;
end


%Unidirectional Transmission Lines
%This prevents flow in both directions, which is important because 
%there is a scenario where the global profits are increased by
%additional customers, which could be wasted electricity if it is cheaper
%than the gas supply, as an artifact of the artifical cost boundary
A=zeros(18,nVar);
b=zeros(18,1);
for i=1:nVar
    a1=edges(i,:);
    % EWA=13;
    % EOR=14;
    % ECA=15;
    % EAZ=16;
    % ENV=17;
    % EID=18;
    if isequal(a1,[EWA EID]) || isequal(a1,[EID EWA])
        A(1,i)=1;
        b(1)=max(b(1),opt_capacity(i));
    elseif isequal(a1,[EWA EOR]) || isequal(a1,[EOR EWA])
        A(2,i)=1;
        b(2)=max(b(2),opt_capacity(i));
    elseif isequal(a1,[EOR EID]) || isequal(a1,[EID EOR])
        A(3,i)=1;
        b(3)=max(b(3),opt_capacity(i));
    elseif isequal(a1,[EOR ENV]) || isequal(a1,[ENV EOR])
        A(4,i)=1;
        b(4)=max(b(4),opt_capacity(i));
    elseif isequal(a1,[EID ENV]) || isequal(a1,[ENV EID])
        A(5,i)=1;
        b(5)=max(b(5),opt_capacity(i));
    elseif isequal(a1,[EOR ECA]) || isequal(a1,[ECA EOR])
        A(6,i)=1;
        b(6)=max(b(6),opt_capacity(i));
    elseif isequal(a1,[ENV ECA]) || isequal(a1,[ECA ENV])
        A(7,i)=1;
        b(7)=max(b(7),opt_capacity(i));
    elseif isequal(a1,[ECA EAZ]) || isequal(a1,[EAZ ECA])
        A(8,i)=1;
        b(8)=max(b(8),opt_capacity(i));
    elseif isequal(a1,[ENV EAZ]) || isequal(a1,[EAZ ENV])
        A(9,i)=1;
        b(9)=max(b(9),opt_capacity(i));
    end
    
    %Gas
    if isequal(a1,[WA ID]) || isequal(a1,[ID WA])
        A(10,i)=1;
        b(10)=max(b(10),opt_capacity(i));
    elseif isequal(a1,[WA OR]) || isequal(a1,[OR WA])
        A(11,i)=1;
        b(11)=max(b(11),opt_capacity(i));
    elseif isequal(a1,[OR ID]) || isequal(a1,[ID OR])
        A(12,i)=1;
        b(12)=max(b(12),opt_capacity(i));
    elseif isequal(a1,[OR NV]) || isequal(a1,[NV OR])
        A(13,i)=1;
        b(13)=max(b(13),opt_capacity(i));
    elseif isequal(a1,[ID NV]) || isequal(a1,[NV ID])
        A(14,i)=1;
        b(14)=max(b(14),opt_capacity(i));
    elseif isequal(a1,[OR CA]) || isequal(a1,[CA OR])
        A(15,i)=1;
        b(15)=max(b(15),opt_capacity(i));
    elseif isequal(a1,[NV CA]) || isequal(a1,[CA NV])
        A(16,i)=1;
        b(16)=max(b(16),opt_capacity(i));
    elseif isequal(a1,[CA AZ]) || isequal(a1,[AZ CA])
        A(17,i)=1;
        b(17)=max(b(17),opt_capacity(i));
    elseif isequal(a1,[NV AZ]) || isequal(a1,[AZ NV])
        A(18,i)=1;
        b(18)=max(b(18),opt_capacity(i));
    end
end

% for i=1:nVar
%     if opt_demand(i) < 0
%         tmp=zeros(1,nVar);
%         tmp(1,i)=1;
%         b(end+1)=-1*opt_demand(i);
%         A(end+1,:)=tmp;
%     end
% end

%lower bound is zero
%lb=zeros(nVar,1);%-opt_demand;
%upper bound is capacity, remeber optimizing flows here
ub=opt_capacity; %Includes Supply
%Upper bound is further reduced by demand
for i=1:nVar
    if opt_demand(i) < 0 && ub(i) > -1*opt_demand(i)
        ub(i)=-1*opt_demand(i);
    end
end

%This section is a little bit messy, but what it does is select
%which utility to optimize 
%The interfaces are seen as unlimited demand/supply (capacity constrained) customers, 
%subject to the incoming constraints "inflows" which define limitations on how much
%each customer will buy

%Mark the supply and load nodes
a_remove=[find(c_demand < 0)' find(c_supply > 0)']';

if gaselec==0
	%Limited supply, but consider all flows in optimization
    ub(inflows>=0)=inflows(inflows>=0);
    outflows_idx=ones(nVar,1);
elseif gaselec==1
    %Select gas-only system for optimization
    %Disable objective for electric utility
    opt_cost(mapped_is_elec==1)=0;
    opt_demand(mapped_is_elec==1)=0;
    ub(mapped_is_elec==1)=0;
    idx=1:length(ub);
    tmp=idx(mapped_is_gen==1);
    tmp=tmp(inflows(tmp)>=0);
    ub(tmp)=inflows(tmp);
    outflows_idx=mapped_is_gas;
    %Remove conservation of flow thru the generators, so it is an offer of supply
    a_remove=[a_remove' GASGENCA GASGENWA GASGENOR GASGENID GASGENNV GASGENAZ];
else %if gaselec==2
    %Allow gas to flow freely
    opt_cost(mapped_is_gas==1)=0;
    %Force restriction on inflows
    ub(mapped_is_gas==1)=0;
    idx=1:length(ub);
    tmp=idx(mapped_is_gas==1);
    tmp=tmp(inflows(tmp)>=0);
    ub(tmp)=inflows(tmp);
    outflows_idx=mapped_is_elec+mapped_is_gen;
    %Remove conservation of flow thru the generators
    %a_remove=[a_remove' GASGENCA GASGENWA GASGENOR GASGENID GASGENNV GASGENAZ];
end

%Forcing the flows on the edges removed from optimization to be unconserved
%I.E. Enabling the non-optimized components to be customers
Aeq(a_remove,:)=zeros(length(a_remove),nVar);
beq=zeros(size(Aeq,1),1);

%if ~isempty(loadnode)
%	beq(loadnode)=varargin{2};
%end

f=opt_cost;

[oflows,~]=linprog(f,A,b,Aeq,beq,lb,ub);
flows=oflows;
%flows(flows<0.5)=0; %Purge noise
oflows=flows;
oflows(outflows_idx==0)=0; %Remove revolving constraints (i.e. don't pass electric flows as constraints back into the electric side)
flows=round(flows);
flows=flows/100;
flows=round(flows);
flows=flows/10;
capgraph=zeros(size(c_capacity));
for i=1:nVar
    capgraph(edges(i,1),edges(i,2))=flows(i);
end

%Plot the result (or not)
if(plotData == 1)
    bg=biograph(capgraph,nodeNames,'ShowWeights','on','ShowArrows','on','LayoutType','hierarchical');
    bg2=create_biograph_obj(capgraph);
    %view(bg2);
    output.bg=bg;
    output.bg2=bg2;
end

%Now calc some costs for output
total_income=-1*sum(oflows.*opt_cost)*60*60;
flow_income=-1*oflows.*opt_cost*60*60;
total_delivery=sum(oflows(opt_demand<0));
total_shortage=-1*total_delivery-sum(opt_demand);
revenue_per_mw=total_income/total_delivery;

output.total_income=total_income;
output.elec_income=sum(flow_income(mapped_is_elec==1));
output.gas_income=sum(flow_income(mapped_is_gas==1));
output.total_delivery=total_delivery;
output.total_shortage=total_shortage;
output.revpermw=revenue_per_mw;

etmp=edges;
etmp(opt_demand==0,:)=[];
ftmp=oflows(opt_demand<0);
ftmp=ftmp+opt_demand(opt_demand<0);
output.fshortage=ftmp;

%keyboard

end



