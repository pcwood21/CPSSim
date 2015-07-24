function [ edges,capacity,cost,loss,extras ] = map_ng_elec_model( ~ )
%MAP_NG_MODEL Summary of this function goes here
%   Detailed explanation goes here

addpath('IDD_Model');
constants;
gas_elec_combi;

[r,c] = find(c_capacity);
edgesfound=[r,c];
nVar=length(edgesfound);
mapped_is_gas=zeros(nVar,1);
mapped_is_elec=zeros(nVar,1);
mapped_is_gen=zeros(nVar,1);
opt_cost=zeros(nVar,1);
opt_capacity=zeros(nVar,1);
opt_loss=zeros(nVar,1);
opt_demand=zeros(nVar,1);
for i=1:nVar
    opt_capacity(i)=c_capacity(edgesfound(i,1),edgesfound(i,2));
    opt_loss(i)=c_loss(edgesfound(i,1),edgesfound(i,2));
    opt_cost(i)=c_cost(edgesfound(i,1),edgesfound(i,2));
    opt_demand(i)=c_demand(edgesfound(i,2));
    mapped_is_elec(i)=(sum(elec_capacity(edgesfound(i,1),:))>0);
    mapped_is_gas(i)=(sum(gas_capacity(edgesfound(i,1),:))>0);
    %if electric out and gas in
    if sum(elec_capacity(edgesfound(i,2),:))>0 && sum(gas_capacity(:,edgesfound(i,2)))>0
        mapped_is_gen(i)=1;
    end
end


edges=edgesfound;
cost=opt_cost;
loss=opt_loss;
capacity=opt_capacity;
for i=1:length(capacity)
    if opt_demand(i) < 0 && capacity(i) > -1*opt_demand(i)
        capacity(i)=-1*opt_demand(i);
    end
end

extras.mapped_is_elec=mapped_is_elec;
extras.mapped_is_gas=mapped_is_gas;

end

