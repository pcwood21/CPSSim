clc
close all;
clear all;

N=7;
%Underlying Game
adjmat=wheel_graph(N);
ntx=N-1+N;
adjmat(3*N,3*N)=0;


%Take nodes 1-2, 3-4, 5-6, 7 as organizations

source_capacity=7;
sink_capacity=4;
link_capacity=15;

capacity=adjmat*link_capacity;
sources=N+1:N+N;
sinks=2*N+1:2*N+N;

for i=1:N
    adjmat(sources(i),i)=1;
    adjmat(i,sinks(i))=1;
    capacity(i,sinks(i))=sink_capacity;
    capacity(sources(i),i)=source_capacity;
end

capacity(sources(end),N)=sink_capacity*N;

nNames={};
for i=1:N
    nNames(i)={['H' num2str(i)]};
    nNames(i+N)={['G' num2str(i)]};
    nNames(i+2*N)={['L' num2str(i)]};
end

nNames(N)={'SH'};

%bg=biograph(capacity,nNames,'ShowWeights','on');
%view(bg);

base_cost=0.01;
sink_cost=-2;
gen_cost=1;
costs=adjmat*base_cost;
for i=1:N
    costs(sources(i),i)=gen_cost;
    costs(i,sinks(i))=sink_cost;
end

costs(sources(end),N)=gen_cost*1.50;

%bg=biograph(costs,nNames,'ShowWeights','on');
%view(bg);

%Ownership Division
owner=zeros(size(adjmat));
for i=1:N-1
    owner(i,mod(i+1,N)+((i+1)>=N))=i;
    owner(i,i-1+(N-1)*((i-1)<1))=i;
    owner(i,sinks(i))=i;
    owner(sources(i),i)=i;
end
%Central Hub
owner(N,1:N-1)=N;
owner(1:N-1,N)=1:N-1;
owner(N,sinks(N))=N;
owner(sources(N),N)=N;

%bg=biograph(owner,nNames,'ShowWeights','on');
%view(bg);
%keyboard
%return;

%Underlying Game
[r,c] = find(capacity);
edges=[r,c];
nVar=size(edges,1);
opt_issink=zeros(nVar,1);
for i=1:nVar
    idx=[edges(i,1) edges(i,2)];
    if any(ismember(sinks,idx(2)))
        opt_issink(i)=1;
    end
end

targets=1:size(edges,1);
targets(opt_issink==1)=[];

rmidx=[];
for i=1:length(targets)
    matches=ismember(edges,[edges(targets(i),2) edges(targets(i),1)],'rows');
    if any(matches)
        rmidx(end+1)=i;
    end
end
%targets(rmidx(1:end/2))=[];

[oflows,base_owner_rev, capgraph]=game_costflowmin(capacity,costs,owner, N, ntx, nNames,sinks,sources);


%bg=biograph(capgraph,nNames,'ShowWeights','on','ShowArrows','on','LayoutType','hierarchical');
%view(bg);


impact_matrix=zeros(length(targets),N);
for i=1:length(targets)
    tcapacity=capacity;
    tcapacity(edges(targets(i),1),edges(targets(i),2))=0;
%    tcapacity(edges(targets(i),2),edges(targets(i),1))=0;
    [~,owner_rev, capgraph]=game_costflowmin(tcapacity,costs,owner, N, ntx, nNames,sinks,sources);
    impact_matrix(i,:)=base_owner_rev-owner_rev;
%    bg=biograph(capgraph,nNames,'ShowWeights','on','ShowArrows','on','LayoutType','hierarchical');
%view(bg);
%keyboard
end

impact_matrix(abs(impact_matrix)<1e-3)=0;


C_d=0.1;
C_a=0.05;

%Adversary
atk_targ=1:length(targets);
intcon=ones(length(atk_targ),1);

%Combination of Adversary
tsum=0;
for k=1:N
    
    C=nchoosek(1:N,k);
    tsum=tsum+size(C,1);
end
tsum

