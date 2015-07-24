function [ impact_matrix ] = create_impact_matrix( linprog_params, ownership, depth )
%CREATE_IMPACT_MATRIX Summary of this function goes here
%   Positive impacts are gains, negative impacts are losses


nEdges=length(linprog_params.f);
nOwners=length(unique(ownership));

impact_matrix=zeros(nEdges,nOwners);

base_profit=assign_profits(ownership,linprog_params);

parfor i=1:nEdges
    tmp_lpp=linprog_params;
    row=zeros(1,size(tmp_lpp.Aeq,2));
    row(i)=1;
    tmp_lpp.Aeq(end+1,:)=row;
    tmp_lpp.beq(end+1)=0;
    try
    new_profit=assign_profits(ownership,tmp_lpp);
    impact_matrix(i,:)=new_profit-base_profit;
    catch e
        %disp e
    end
end

end

