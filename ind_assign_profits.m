function [ profits ] = ind_assign_profits( ownership,linprog_params_cell,baseline_linprog_params )
%IND_ASSIGN_PROFITS Summary of this function goes here
%   This function assigns profits for independent views of the system


%Determine per-edge customer base, could use as input instead of fixed
[ edges,~ ] = map_ng_elec_model();

edge_customer=zeros(size(edges,2),max(ownership));
for i=1:size(edges,1)
    dst=edges(i,2);
    for k=1:size(edges,1)
        if dst==edges(k,1)
            edge_customer(i,ownership(k))=1;
        end
    end
end

owners=unique(ownership);
nOwners=length(owners);
nAssets=length(ownership);

marg_profits=zeros(length(linprog_params_cell),length(linprog_params_cell{1}.f));

for i=1:length(linprog_params_cell)
	linprog_params=linprog_params_cell{i};
	[~,marg_profits(i,:)]=assign_profits(ownership,linprog_params);
end


final_f=baseline_linprog_params.f;
for i=1:size(marg_profits,2)
    if final_f(i) ~= 0
        continue;
    end
    
    fval=0;
    tmp=marg_profits(edge_customer(i,:)==1,i);
    if isempty(tmp) %No customer edge, i.e. final edge
        fval=marg_profits(ownership(i),i);
    else
    
    fval=mean(tmp);
    end

    final_f(i)=fval;
end

tlpp=baseline_linprog_params;
tlpp.f=final_f;
[tmp,base_flows]=optimize_cost(tlpp);
base_cost=sum(baseline_linprog_params.f.*base_flows);


profit_point=zeros(nAssets,1);
profit_amount=zeros(nAssets,1);
profit_point(baseline_linprog_params.f == 0) =1;
for i=1:nAssets
    if profit_point(i) == 1
        profit_amount(i)=final_f(i)*base_flows(i);
    end
end

%Now calculate profit at customers

base_idx=1:length(baseline_linprog_params.f);
base_Aeq=baseline_linprog_params.Aeq;
base_beq=baseline_linprog_params.beq;
base_beq_idx=length(base_beq);

tmp_lpp=baseline_linprog_params;
tmp_lpp.f=final_f;
[pbase_cost,~]=optimize_cost(tmp_lpp);
for i=1:nAssets
    if baseline_linprog_params.f(i) < 0 && base_flows(i) > 0%Customer
        
        %Perform marginal impact analysis
        tmp_lpp=baseline_linprog_params;
        tmp_lpp.f=final_f;
        Aeq=base_Aeq;
        beq=base_beq;
        row=zeros(1,size(base_Aeq,2));
        row(i)=1;
        Aeq(end+1,:)=row;
        beq(end+1)=base_flows(i)-1;
        tmp_lpp.Aeq=Aeq;
        tmp_lpp.beq=beq;
        try
        [impact1,~]=optimize_cost(tmp_lpp);
        %try
        %tmp_lpp.beq(end)=base_flows(i)+1;
        %[impact2,~]=optimize_cost(tmp_lpp);
        %impact=(impact1-impact2)/2
        %catch
            impact=impact1;
        %end
        margin_profit=impact-pbase_cost;
        if margin_profit < 0
            margin_profit=0;
        end
        profit_amount(i)=margin_profit*base_flows(i);
        catch
            profit_amount(i)=0;
        end
    end
end

profits=zeros(nOwners,1);
for i=1:nOwners
    profits(i)=sum(profit_amount(ownership==i));
end

missing_profits=abs(base_cost+sum(profits));
scale=abs(missing_profits/base_cost);
profits=profits.*(1+scale);




end

