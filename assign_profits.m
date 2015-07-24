function [ profits, f ] = assign_profits( ownership,linprog_params )
%ASSIGN_PROFITS Summary of this function goes here
%   Detailed explanation goes here

owners=unique(ownership);
nOwners=length(owners);
nAssets=length(ownership);

[base_cost,base_flows]=optimize_cost(linprog_params);

base_idx=1:length(linprog_params.f);
base_Aeq=linprog_params.Aeq;
base_beq=linprog_params.beq;
base_beq_idx=length(base_beq);

margin_cost=zeros(nAssets,1);

for o=1:nOwners
    
    tmp_lpp=linprog_params;
    nAssets_owner=sum(ownership==o);
    margin_cost_owner=zeros(nAssets_owner,1);
    
    %Fix flow for owner's assets
    fixed_flow=base_flows(ownership==o);
    fixed_flow_idx=base_idx(ownership==o);
    for i=1:length(fixed_flow)
        row=zeros(1,size(base_Aeq,2));
        row(fixed_flow_idx(i))=1;
        tmp_lpp.Aeq(end+1,:)=row;
        tmp_lpp.beq(end+1,:)=fixed_flow(i);
    end
    
    %Find margin cost for each asset independently
    for i=1:nAssets_owner
        %Reduce flow on leg
        if abs(fixed_flow(i)) >= 1
        tmp_lpp.beq(base_beq_idx+i)=tmp_lpp.beq(base_beq_idx+i)-1;
        [impact,~]=optimize_cost(tmp_lpp);
        tmp_lpp.beq(base_beq_idx+i)=tmp_lpp.beq(base_beq_idx+i)+1;
        margin_cost_owner(i)=impact-base_cost;
        end
    end
    
    margin_cost(ownership==o)=margin_cost_owner;

end

%Prune noise
margin_cost(margin_cost<0)=0;


%Now seeking feasible profit assignment
nRounds=10; %Number of times to search for valid assignment
f=linprog_params.f;
last_f=f;
skip=zeros(nAssets,1);
skip(f~=0)=1; %Skip all the customers and suppliers
found_round=zeros(nAssets,1);
found_round(skip==1)=-1;
for k=nRounds:-1:1
    div=(2^(k-1));
    for i=1:nAssets
        if skip(i) ~= 1
            last_f(i)=f(i);
            f(i)=margin_cost(i)/div;
        end
    end
    tmp_lpp=linprog_params;
    tmp_lpp.f=f;
    [~,new_flows]=optimize_cost(tmp_lpp);
    change_in_flow=sum(abs(base_flows-new_flows));
    
    if change_in_flow > 1
        cflows=base_flows-new_flows;
        acflows=abs(cflows);
        for i=1:nAssets
            if skip(i) ~= 1 && acflows(i) > 1
                tmpf=f(i);
                f(i)=last_f(i);
                tmp_lpp=linprog_params;
                tmp_lpp.f=f;
                [~,new_flows]=optimize_cost(tmp_lpp);
                nchange_in_flow=sum(abs(base_flows-new_flows));
                %tcflows=base_flows(i)-new_flows(i)-cflows(i)
                if nchange_in_flow < change_in_flow
                    skip(i)=1;
                    found_round(i)=k;
                else
                    f(i)=tmpf;
                end
            end
        end
        tmp_lpp=linprog_params;
        tmp_lpp.f=f;
        [~,new_flows]=optimize_cost(tmp_lpp);
        cflows=base_flows-new_flows;
        acflows=abs(cflows);
        change_in_flow=sum(abs(base_flows-new_flows));
        if change_in_flow > 1
            f(skip==0)=last_f(skip==0);
            for i=1:nAssets
                if skip(i)~= 1 
                    f(i)=margin_cost(i)/div;
                    tmp_lpp=linprog_params;
                    tmp_lpp.f=f;
                    [~,new_flows]=optimize_cost(tmp_lpp);
                    nchange_in_flow=sum(abs(base_flows-new_flows));
                    if nchange_in_flow > 1
                        skip(i)=1;
                        found_round(i)=k;
                        f(i)=last_f(i);
                    end
                end
            end
        end
        tmp_lpp=linprog_params;
        tmp_lpp.f=f;
        [~,new_flows]=optimize_cost(tmp_lpp);
        change_in_flow=sum(abs(base_flows-new_flows));
        if change_in_flow > 1
            keyboard
        end
    end
end

%keyboard
%Now f has the profits allowed

profit_point=zeros(nAssets,1);
profit_amount=zeros(nAssets,1);
profit_point(linprog_params.f == 0) =1;
for i=1:nAssets
    if profit_point(i) == 1
        profit_amount(i)=f(i)*base_flows(i);
    end
end

%Now calculate profit at customers

tmp_lpp=linprog_params;
tmp_lpp.f=f;
[pbase_cost,~]=optimize_cost(tmp_lpp);
for i=1:nAssets
    if linprog_params.f(i) < 0 && base_flows(i) > 0%Customer
        
        %Perform marginal impact analysis
        tmp_lpp=linprog_params;
        tmp_lpp.f=f;
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

