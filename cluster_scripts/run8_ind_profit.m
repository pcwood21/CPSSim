function output = run8_ind_profit(noise,nOwners,mc_num)

%Import the NG model as edges, capacity, cost, and loss ground truth
[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[total_cost,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;
nEdges=length(edges);

ind_profits_mc=zeros(mc_num,nOwners);
orig_profits_mc=zeros(mc_num,nOwners);
rand_own_mc=zeros(mc_num,nEdges);

for j=1:mc_num

rand_own=randi([1,nOwners],[nEdges,1]);
ownership=rand_own;

for i=1:nOwners
    tlpp=add_noise_lpp(linprog_params,noise);
    tlpp.f(ownership==i)=linprog_params.f(ownership==i);
    tlpp.ub(ownership==i)=linprog_params.ub(ownership==i);
    linprog_params_cell{i}=tlpp;
end

[ind_profits] = ind_assign_profits(ownership,linprog_params_cell,linprog_params);
[orig_profits] = assign_profits(ownership,linprog_params);

ind_profits_mc(j,:)=ind_profits;
orig_profits_mc(j,:)=orig_profits;
rand_own_mc(j,:)=rand_own;

end

output.ind_profits=ind_profits_mc;
output.orig_profits=orig_profits_mc;
output.ownership=rand_own_mc;
output.noise=noise;
output.nOwners=nOwners;
output.mc_num=mc_num;



end