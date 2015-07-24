function [ oflows, owner_rev, capgraph ] = game_costflowmin( capacity, costs,owner, N, ntx , nNames,sinks,sources)
%GAME_COSTFLOWMIN Summary of this function goes here
%   Detailed explanation goes here

[r,c] = find(capacity);
edges=[r,c];
nVar=size(edges,1);
opt_capacity=zeros(nVar,1);
opt_cost=zeros(nVar,1);
opt_owner=zeros(nVar,1);
opt_issink=zeros(nVar,1);
opt_issource=zeros(nVar,1);
opt_istrans=zeros(nVar,1);
for i=1:nVar
    idx=[edges(i,1) edges(i,2)];
    opt_capacity(i)=capacity(idx(1),idx(2));
    opt_cost(i)=costs(idx(1),idx(2));
    opt_owner(i)=owner(idx(1),idx(2));
    if any(ismember(sinks,idx(2)))
        opt_issink(i)=1;
    elseif any(ismember(sources,idx(1)))
        opt_issource(i)=1;
    else
        opt_istrans(i)=1;
    end
end

%Zero-sum nodes
Aeq=zeros(N,nVar);
for i=1:N
    row=zeros(1,nVar);
    for k=1:nVar
        if edges(k,1)==i
            row(k)=-1;
        elseif edges(k,2)==i
            row(k)=1;
        end
    end
    Aeq(i,:)=row;
end
beq=zeros(size(Aeq,1),1);

%Unidirectional Transmission
%In the form A*flow <= b
A=zeros(ntx*2,nVar);
b=zeros(ntx*2,1);
k=1;
for i=1:length(edges)
    matches=ismember(edges,[edges(i,2) edges(i,1)],'rows');
    if any(matches)
        A(k,:)=zeros(1,length(edges));
        A(k,i)=1;
        A(k,matches)=1;
        b(k)=opt_capacity(i);
        k=k+1;
    end
end

%Remove duplicates
[A,bidx]=unique(A,'rows');
btmp=b(bidx);
b=btmp;
%Upper and Lower Bounds
ub=opt_capacity;
lb=zeros(length(edges),1);

f=opt_cost;



% new_ub=ub;
% %Per-Owner Optimizations to create lower/upper bound
% stopflow=zeros(nVar,1);
% joint_flows=zeros(nVar,1);
% out_avail=zeros(nVar,1);
% in_request=zeros(nVar,1);
% %Maximize own profit first
% for k=1:1
% 
% for i=1:max(opt_owner)
%     %Know c
%     %keyboard
%     tf=opt_cost;
%     tf(opt_owner~=i)=min(opt_cost(opt_owner==i))*-10;
%     tAeq=Aeq;
%     %Outbound transmissions to other hubs do not block on conservation
%     %idx=ones(max(opt_owner),1);
%     %idx(i)=0;
%     %tAeq(idx==1,opt_owner==i & opt_istrans)=0;
%     %new_ub=ub;
%     %new_ub(opt_issink==1 & opt_owner~=i)=0;
%     %
%     [oflows,~]=linprog(tf,A,b,tAeq,beq,lb,ub);
%     oflows(oflows<1e-2)=0;
%     out_avail(opt_owner==i & opt_istrans)=oflows(opt_owner==i & opt_istrans);
%     aidx=tAeq(idx==0,:);
%     aidx(aidx<0)=0;
%     aidx(opt_istrans==0)=0;
%     aidx(opt_owner==i & opt_istrans)=0;
%     in_request(aidx==1)=oflows(aidx==1);
%     keyboard
% end
% 
% 
% end
% keyboard
% 
% joint_flows=oflows;
% capgraph=zeros(size(capacity));
% for m=1:nVar
%     capgraph(edges(m,1),edges(m,2))=joint_flows(m);
% end
% bg=biograph(capgraph,nNames,'ShowWeights','on','ShowArrows','on','LayoutType','hierarchical');
% view(bg);
% keyboard  

[oflows,~]=linprog(f,A,b,Aeq,beq,lb,ub);
oflows(oflows<1e-2)=0;

capgraph=zeros(size(capacity));
for i=1:nVar
    capgraph(edges(i,1),edges(i,2))=oflows(i);
end



owner_rev=zeros(max(opt_owner),1);
ind_opt_cost=opt_cost;
for i=1:max(opt_owner)
     ind_opt_cost(opt_owner==i & opt_istrans)=0.9*min(opt_cost(opt_owner==i))+0.1;
     idx=ones(max(opt_owner),1);
     idx(i)=0;
     aidx=Aeq(idx==0,:);
     aidx(aidx<0)=0;
     aidx(opt_istrans==0)=0;
     aidx(opt_owner==i & opt_istrans)=0;
     ind_opt_cost(aidx==1)=-0.9*min(opt_cost(opt_owner==i))+0.1;
     owner_rev(i)=-1*sum([(oflows(opt_owner==i).*ind_opt_cost(opt_owner==i))' (oflows(aidx==1).*ind_opt_cost(aidx==1))']);
end



end

