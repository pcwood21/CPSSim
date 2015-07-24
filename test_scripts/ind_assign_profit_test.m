[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[total_cost,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;

base_cost=total_cost;
base_flows=flows;
nEdges=length(edges);

%Create edge ownership assignments
single_ownership=ones(nEdges,1);

gaselec_ownership=zeros(nEdges,1);
gaselec_ownership(extras.mapped_is_gas==1)=1;
gaselec_ownership(extras.mapped_is_elec==1)=2;

nOwners=16;
random_ownership=randi([1,nOwners],[nEdges,1]);

ownership=random_ownership;
noise_amt=0.1;
for i=1:nOwners
    tlpp=add_noise_lpp(linprog_params,noise_amt);
    tlpp.f(ownership==i)=linprog_params.f(ownership==i);
    tlpp.ub(ownership==i)=linprog_params.ub(ownership==i);
    linprog_params_cell{i}=tlpp;
end

[ind_profits] = ind_assign_profits(ownership,linprog_params_cell,linprog_params);
[orig_profits] = assign_profits(ownership,linprog_params);


