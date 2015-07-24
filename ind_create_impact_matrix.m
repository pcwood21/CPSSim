function [ impact_matrix ] = ind_create_impact_matrix( linprog_params_cell,linprog_params, ownership )
%CREATE_IMPACT_MATRIX Summary of this function goes here
%   Positive impacts are gains, negative impacts are losses


nEdges=length(linprog_params.f);
nOwners=length(unique(ownership));

impact_matrix=zeros(nEdges,nOwners);

base_profit=ind_assign_profits(ownership,linprog_params_cell,linprog_params);

parfor i=1:nEdges
    tmp_blpp=linprog_params;
    row=zeros(1,size(tmp_blpp.Aeq,2));
    row(i)=1;
    tmp_blpp.Aeq(end+1,:)=row;
    tmp_blpp.beq(end+1)=0;

    tlppcell=cell();
    for j=1:length(linprog_params_cell)
    tmp_lpp=linprog_params_cell{j};
    row=zeros(1,size(tmp_lpp.Aeq,2));
    row(i)=1;
    tmp_lpp.Aeq(end+1,:)=row;
    tmp_lpp.beq(end+1)=0;
    tlppcell{i}=tmp_lpp;
    end
    try
    new_profit=ind_assign_profits(ownership,tlppcell,tmp_blpp);
    impact_matrix(i,:)=new_profit-base_profit;
    catch e
        %disp e
    end
end

end

