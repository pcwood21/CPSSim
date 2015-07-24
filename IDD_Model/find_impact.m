%This is the study file which enacts different scenarios and has a large plotting component


clear all;
gas_elec_combi;

%Define how much capacity reduction each edge should have (1-1.0 is 100% failure)
attackAmount=1-1.0;

%Rebuild the edge map for processing later
[r,c] = find(c_capacity);
edgesfound=[r,c];

nVar=length(edgesfound);
mapped_is_gas=zeros(nVar,1);
mapped_is_elec=zeros(nVar,1);
mapped_is_gen=zeros(nVar,1);
opt_cost=zeros(nVar,1);
opt_capacity=zeros(nVar,1);
opt_loss=zeros(nVar,1);
for i=1:nVar
    opt_capacity(i)=c_capacity(edgesfound(i,1),edgesfound(i,2));
    opt_loss(i)=c_loss(edgesfound(i,1),edgesfound(i,2));
    opt_cost(i)=c_cost(edgesfound(i,1),edgesfound(i,2));
    mapped_is_elec(i)=(sum(elec_capacity(edgesfound(i,1),:))>0);
    mapped_is_gas(i)=(sum(gas_capacity(edgesfound(i,1),:))>0);
    %if electric out and gas in
    if sum(elec_capacity(edgesfound(i,2),:))>0 && sum(gas_capacity(:,edgesfound(i,2)))>0
        mapped_is_gen(i)=1;
    end
end

%Define the variables
%Start with no inflows
def_inflows=ones(length(edgesfound),1)*-1;
%Evaluate a baseline flow optimization
[baseoutput,combiflows]=mincost_flow([],[],[],1,0,def_inflows);
%Now have the base profits
baseRev=baseoutput.total_income;


%Loop thru each edge and attack it, and then record the impact with the single optimization point (global welfare)
%edgeMargImpact=zeros(nVar,1);
%edgeLoss=zeros(nVar,1);
%flowdiff=zeros(nVar,1);
%tflowdiff=zeros(nVar,1);

customer_nodes=[GASGENWA GASGENOR GASGENCA GASGENAZ GASGENNV GASGENID];
customer_edges=zeros(nVar,1);
for i=1:nVar
    if find(customer_nodes==edgesfound(i,2))
        customer_edges(i)=i;
    end
end
cedges=unique(customer_edges(customer_edges>0));

tcost=opt_cost;
old_tcost=zeros(nVar,1);
nZeroCost=length(opt_cost(opt_cost==0));
skip=zeros(nVar,1);
eround=zeros(nVar,2);
for i=1:length(cedges)
    if combiflows(cedges(i)) <= 1
        tcost(cedges(i))=10;
    end
end
[tout1,ncombiflows]=mincost_flow([],[],[],1,0,def_inflows,tcost);
lowcostdiff=sum(abs(combiflows-ncombiflows))

%{
for j=1:length(cedges)
    i=cedges(j);
        if combiflows(i) > 1
            [outputnorm,~]=mincost_flow([],[],[],0,0,def_inflows,cedges,combiflows(cedges),opt_cost);
            tmpflow=combiflows(cedges);
            tmpflow(j)=tmpflow(j)-1;

            [outputmarg,~]=mincost_flow([],[],[],0,0,def_inflows,cedges,tmpflow,opt_cost);
            edgeMargImpact=(outputnorm.gas_income-outputmarg.gas_income)
            new_cost=edgeMargImpact/60/60*0.33;
            %tcost(i)=new_cost;
            %keyboard
        end
end
[tout2,ncombiflows]=mincost_flow([],[],[],1,0,def_inflows,tcost);
lowcostdiff=sum(abs(combiflows-ncombiflows))
lowprofits=sum(tcost(cedges).*combiflows(cedges)*60*60)
%}
%return;

lowprofitk=zeros(30,1);
costval=zeros(30,length(cedges));
old_profit=zeros(length(cedges),1);
for k=1:30
for j=1:length(cedges)
    i=cedges(j);
    if combiflows(i) > 1 && skip(i)==0
        new_cost=5e-5*k;
        old_cost=tcost(i);
        tcost(i)=new_cost;
        %Validate non-perturbation
        fail=0;
        new_profit=0;
        try
        [tout,ncombiflows]=mincost_flow([],[],[],0,0,def_inflows,tcost);
        new_profit=tout.gas_income;
        catch
            fail=1;
        end
        if fail==1 || sum(abs(combiflows-ncombiflows)) > 1
            tcost(i)=old_cost;
            skip(i)=1;
            eround(i,:)=[k sum(abs(combiflows-ncombiflows))];
        end
        old_profit(j)=new_profit;
    end

end
end
[tout,ncombiflows]=mincost_flow([],[],[],0,0,def_inflows,tcost);
highcostdiff=sum(abs(combiflows-ncombiflows))
highprofits=tout.gas_income+2*sum(tcost(cedges).*combiflows(cedges)*60*60)
tout


%Calc gas profits
gcost=opt_cost(mapped_is_gas==1);
tgcost=tcost(mapped_is_gas==1);

costmarg=zeros(nVar,1);
for j=1:nVar
    if mapped_is_gas(j)==1 && opt_cost(j) < 0 && combiflows(j) > 0
        [outputnorm,~]=mincost_flow([],[],[],0,0,def_inflows,j,combiflows(j),opt_cost);
        
        [outputmarg,~]=mincost_flow([],[],[],0,0,def_inflows,j,combiflows(j)-1,opt_cost);
        edgeMargImpact=(outputnorm.total_income-outputmarg.total_income)
        namesrevidx(edgesfound(j,:))
        if edgeMargImpact > 0
            %edgeMargImpact = 0;
        end
        costmarg(j)=edgeMargImpact;
    end
end
return;

%edgeMargImpact=floor(edgeMargImpact*10)/10;
%max(edgeLoss)
%max(tflowdiff)
%max(flowdiff)
%return;

%new_opt_cost=zeros(nVar,1);
%for i=1:nVar
%    if opt_cost(i) == 0 && combiflows(i) > 0
%    new_cost=edgeMargImpact(i)/60/60/2;
%    new_opt_cost(i)=new_cost;
%    end
%end

new_opt_cost=tcost;
%new_opt_cost=new_opt_cost*0.75;
%toptcost=opt_cost;
%toptcost(toptcost==0)=new_opt_cost(toptcost==0);

%For viewing
%round([edgesfound(new_opt_cost>0,:) new_opt_cost(new_opt_cost>0)*1e5 edgeImpact(new_opt_cost>0)])

[nbaseoutput,ncombiflows]=mincost_flow([],[],[],1,0,def_inflows,tcost);

tmp=round(ncombiflows-combiflows);

round([edgesfound(new_opt_cost>0,:) new_opt_cost(new_opt_cost>0)*1e6 tmp(new_opt_cost>0)])

distProfits=baseRev-nbaseoutput.total_income;

return;
keyboard


%Find which elements are nodes, i.e. have both an in and out edge
srcs=unique(edgesfound(:,1));
dsts=unique(edgesfound(:,2));
nodes=[];
for i=1:length(dsts)
    node=find(srcs==dsts(i));
    if ~isempty(node)
        nodes(end+1)=node;
    end
end
posnodeImpact=zeros(length(nodes),1);
negnodeImpact=zeros(length(nodes),1);

%Now want to calculate the marginal costs at each node, with 1 MW of change
for i=1:length(nodes)
    try
    output=mincost_flow([],[],[],1,0,def_inflows,nodes(i),1);
    posnodeImpact(i)=baseRev-output.total_income;
    catch
        posnodeImpact(i)=0;
    end
    try
	output=mincost_flow([],[],[],1,0,def_inflows,nodes(i),-1);
    negnodeImpact(i)=-1*(baseRev-output.total_income);
    catch
        negnodeImpact(i)=0;
    end
end

marginalNodeImpact=max(negnodeImpact,posnodeImpact);

new_opt_cost=zeros(nVar,1);
for i=1:nVar
    if opt_cost(i) == 0
    new_cost=marginalNodeImpact(edgesfound(i,2))-marginalNodeImpact(edgesfound(i,1));
    new_cost=new_cost/(60*60); %Convert to MW-second costs
    new_opt_cost(i)=new_cost;
    end
end

tcost=opt_cost+new_opt_cost;

revenues=sum(combiflows(new_opt_cost<0).*new_opt_cost(new_opt_cost<0));
expenses=sum(combiflows(new_opt_cost>0).*new_opt_cost(new_opt_cost>0));



[nbaseoutput,ncombiflows]=mincost_flow([],[],[],1,0,def_inflows,opt_cost+new_opt_cost);

return;
keyboard

%Loop thru each edge and attack it, and then record the impact with the single optimization point (global welfare)
edgeImpact=zeros(size(edgesfound,1),1);

for i=1:size(edgesfound,1)
    output=mincost_flow(edgesfound(i,:),[],0,1,0,def_inflows);
    edgeImpact(i)=baseRev-output.total_income;
end

edgeImpact=round(edgeImpact);
edgeImpact_gas=round(edgeImpact_gas);
edgeImpact_elec=round(edgeImpact_elec);
edgeShortage=round(edgeShortage);

%Take the top 5 impacted edges and sweep the reduction magnitude from 0 to 100%
[vals,idxs]=sort(unique(edgeImpact),'descend');
atkval=0:0.01:1;
magimpact=zeros(5,length(atkval));
for i=1:5
    idx=find(edgeImpact==vals(i),1,'first');
for k=1:length(atkval)
    output=mincost_flow(edgesfound(idx,:),[],atkval(k),1,0,def_inflows);
    magimpact(i,k)=baseRev-output.total_income;
end
end

%Do the same thing but for nodes impacted
nodeImpact=zeros(length(edgesfound),1);
nodeShortage=zeros(length(edgesfound),1);
nodeImpactData={};
nodes=unique(edgesfound);

for i=1:length(nodes)
    output=mincost_flow([],nodes(i),attackAmount,1,0,def_inflows);
    nodeImpact(i)=baseRev-output.total_income;
    nodeShortage(i)=output.total_shortage;
    nodeImpactData{end+1}=output;
end

nodeImpact=round(nodeImpact);
nodeShortage=round(nodeShortage);


%Independent Cost Optimizations
ind_edgeImpact=zeros(length(edgesfound),1);
ind_edgeImpact_gas=zeros(length(edgesfound),1);
ind_edgeImpact_elec=zeros(length(edgesfound),1);
ind_edgeShortage=zeros(length(edgesfound),1);
ind_edgeImpactData={};


%Define the baseline revenue in the independent actor model


%Calc gas availability
[output,gflows]=mincost_flow([],[],0,1,1,def_inflows);
%view(output.bg2)
flows=zeros(length(gflows),1);
newflows=ones(length(gflows),1);
while ~isequal(round(flows*10),round(newflows*10))
    newflows=flows;
    %Determine elec flow given gas availabiltiy
    [output,eflows]=mincost_flow([],[],0,1,2,gflows);
    %view(output.bg2)
    %Re-pass into gas based on demand
    [output,gflows]=mincost_flow([],[],0,1,1,eflows);
    %view(output.bg2)
    flows=eflows+gflows;
    %     [output,~]=mincost_flow([],[],0,1,0,flows);
    %     view(output.bg2);
    %     keyboard
end

%Now solve the system
flows=eflows+gflows;
[output,ind_flows]=mincost_flow([],[],0,1,0,flows);
ind_baseRev=output.total_income;
ind_baseRev_elec=output.elec_income;
ind_baseRev_gas=output.gas_income;

%Repeat with attacked edges
for i=1:size(edgesfound,1)
    %Calc gas availability
    [~,gflows]=mincost_flow(edgesfound(i,:),[],attackAmount,0,1,def_inflows);
    %view(output.bg2)
    flows=zeros(length(gflows),1);
    newflows=ones(length(gflows),1);
    while ~isequal(round(flows*10),round(newflows*10))
        newflows=flows;
        %Determine elec flow given gas availabiltiy
        [~,eflows]=mincost_flow(edgesfound(i,:),[],attackAmount,0,2,gflows);
        %view(output.bg2)
        %Re-pass into gas based on demand
        [~,gflows]=mincost_flow(edgesfound(i,:),[],attackAmount,0,1,eflows);
        %view(output.bg2)
        flows=eflows+gflows;
        %     [output,~]=mincost_flow([],[],0,1,0,flows);
        %     view(output.bg2);
        %     keyboard
    end
    
    %Now solve the system
    %flows=eflows+gflows;
    [output,~]=mincost_flow(edgesfound(i,:),[],attackAmount,0,0,flows);
    
    ind_edgeImpact(i)=ind_baseRev-output.total_income;
    ind_edgeImpact_elec(i)=ind_baseRev_elec-output.elec_income;
    ind_edgeImpact_gas(i)=ind_baseRev_gas-output.gas_income;
    ind_edgeShortage(i)=output.total_shortage;
    ind_edgeImpactData{end+1}=output;
end

ind_edgeImpact=round(ind_edgeImpact);
ind_edgeImpact_gas=round(ind_edgeImpact_gas);
ind_edgeImpact_elec=round(ind_edgeImpact_elec);
ind_edgeShortage=round(ind_edgeShortage);

return;



















%%%%%Begin Graphing Section
%Hilight graph area and execute

%Graph the Edge Impact
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=edgeImpact(i);
end
%in 1k$/hr
capgraph=round(capgraph/100)/10;
%in $/hr
%capgraph=round(capgraph);

bg2=create_biograph_obj(capgraph);
set(bg2,'label','Combined EdgeImpact');
view(bg2);


%Graph the Edge Shortage
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=edgeShortage(i);
end

capgraph=round(capgraph/100)/10;

bg2=create_biograph_obj(capgraph);
set(bg2,'label','Combined Shortage');
view(bg2);


%Graph difference in Independence
flows=combiflows-ind_flows;
flows=round(flows/100)/10;
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=flows(i);
end

bg2=create_biograph_obj(capgraph);
set(bg2,'label','Flow Difference');
view(bg2);


%Graph Independent Edge Impacts
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=ind_edgeImpact_gas(i);
end
%in 1k$/hr
capgraph=round(capgraph/100)/10;
%in $/hr
%capgraph=round(capgraph);
bg2=create_biograph_obj(capgraph);
set(bg2,'label','Independent EdgeImpact');
view(bg2);

%Graph Independent Edge Impacts
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=ind_edgeImpact_elec(i);
end
%in 1k$/hr
capgraph=round(capgraph/100)/10;
%in $/hr
%capgraph=round(capgraph);
bg2=create_biograph_obj(capgraph);
set(bg2,'label','Independent EdgeImpact');
view(bg2);

%Graph Independent Difference Impacts
tdiff1=ind_edgeImpact_elec-ind_edgeImpact_gas;
tdiff1(mapped_is_elec==1)=0;
tdiff1(tdiff1<0)=0;
tdiff2=ind_edgeImpact_gas-ind_edgeImpact_elec;
tdiff2(mapped_is_gas==1)=0;
tdiff2(tdiff2<0)=0;
tdiff=tdiff1+tdiff2;
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=tdiff(i);
end
%in 1k$/hr
capgraph=round(capgraph/100)/10;
%in $/hr
%capgraph=round(capgraph);
bg2=create_biograph_obj(capgraph);
set(bg2,'label','Independent EdgeImpact');
view(bg2);




%Graph Independent Edge Impacts Difference
capgraph=zeros(size(c_capacity));
for i=1:size(edgesfound,1)
    capgraph(edgesfound(i,1),edgesfound(i,2))=ind_edgeImpact(i)-edgeImpact(i);
end
%capgraph(capgraph~=0)=capgraph(capgraph~=0)+baseRev-ind_baseRev;
%in 1k$/hr
capgraph=round(capgraph/100)/10;
%in $/hr
%capgraph=round(capgraph);
bg2=create_biograph_obj(capgraph);
set(bg2,'label','Difference in EdgeImpact');
view(bg2);


%Attack Strategy Analysis

%impact vs flow
attackFlows=[combiflows edgeImpact];
attackFlows(combiflows==0,:)=[];
eiTmp=attackFlows';
eiTmp=eiTmp(2,:);
attackFlows(eiTmp==0,:)=[];
tmp=sortrows(attackFlows,1);
figure
notmp=tmp([22 35],:);
tmp([22 35],:)=[];
hold on;
plot(tmp(:,1)/1000,tmp(:,2)/1000,'.', 'markersize', 20);
plot(notmp(1,1)/1000,notmp(1,2)/1000,'s','LineWidth',3, 'markersize', 10);
plot(notmp(2,1)/1000,notmp(2,2)/1000,'o','LineWidth',3, 'markersize', 10);
hold off;
set(gca,'FontSize',14,'FontWeight','bold');
xh=xlabel('Energy Flow (GW)');
yh=ylabel('Impact (k$/hr)');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
grid on;

pointimpact=zeros(2,length(atkval));
for i=1:2
    idx=find(edgeImpact==notmp(i,2),1,'first');
for k=1:length(atkval)
    output=mincost_flow(edgesfound(idx,:),[],atkval(k),1,0,def_inflows);
    pointimpact(i,k)=baseRev-output.total_income;
end
end

figure;
hold on;
pstyles={'-','--',':','-.','--'};
for i=1:2
    idx=find(edgeImpact==notmp(i,2),1,'first');
plot((atkval(1:end))*100*opt_capacity(idx)/1e6,fliplr(pointimpact(i,:)/1000),pstyles{i},'linewidth',2.5);
end
hold off;
set(gca,'FontSize',14,'FontWeight','bold');
xh=xlabel('Capacity Reduction (GW)');
yh=ylabel('\delta Impact per GW Reduction (k$/hr)');
lh=legend('Square','Circle');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
ylim([0 120]);
%xlim([0 100]);
grid on;


%impact vs capacity
attackFlows=[opt_capacity edgeImpact];
attackFlows(opt_capacity==0,:)=[];
eiTmp=attackFlows';
eiTmp=eiTmp(2,:);
attackFlows(eiTmp==0,:)=[];
tmp=sortrows(attackFlows,1);
figure
notmp=tmp([25 52],:);
tmp([25 52 53],:)=[];
hold on;
plot(tmp(:,1)/1000,tmp(:,2)/1000,'.', 'markersize', 20);
plot(notmp(1,1)/1000,notmp(1,2)/1000,'s','LineWidth',2, 'markersize', 10);
plot(notmp(2,1)/1000,notmp(2,2)/1000,'o','LineWidth',2, 'markersize', 10);
hold off;
xh=xlabel('Energy Capacity (GW)');
yh=ylabel('Impact (k$/hr)');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
grid on;


pointimpact=zeros(2,length(atkval));
for i=1:2
    idx=find(edgeImpact==notmp(i,2),1,'first');
for k=1:length(atkval)
    output=mincost_flow(edgesfound(idx,:),[],atkval(k),1,0,def_inflows);
    pointimpact(i,k)=baseRev-output.total_income;
end
end

figure;
hold on;
pstyles={'-','--',':','-.','--'};
for i=1:2
    idx=find(edgeImpact==notmp(i,2),1,'first');
plot((atkval(1:end))*100,fliplr(pointimpact(i,:)/1000),pstyles{i},'linewidth',2.5);
end
hold off;
xh=xlabel('Capacity Reduction (%)');
yh=ylabel('Change in Impact per % Reduction (k$/hr)');
lh=legend('Square','Circle');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
ylim([0 180]);
%xlim([0 100]);
grid on;


%impact vs loss
%opt_loss(opt_loss>0.1)=0;
opt_totloss=opt_loss.*combiflows;
attackFlows=[opt_totloss edgeImpact];
attackFlows(opt_totloss==0,:)=[];
eiTmp=attackFlows';
eiTmp=eiTmp(2,:);
attackFlows(eiTmp==0,:)=[];
tmp=sortrows(attackFlows,1);
figure
notmp=tmp([15 17],:);
tmp([15 17],:)=[];
hold on;
plot(tmp(:,1)/1000,tmp(:,2)/1000,'.',  'markersize', 20);
plot(notmp(1,1)/1000,notmp(1,2)/1000,'s','LineWidth',2,  'markersize', 10);
plot(notmp(2,1)/1000,notmp(2,2)/1000,'o','LineWidth',2,  'markersize', 10);
hold off;
xh=xlabel('Lost Energy (MW)');
yh=ylabel('Impact (k$/hr)');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
grid on;

pointimpact=zeros(2,length(atkval));
for i=1:2
    idx=find(edgeImpact==notmp(i,2),1,'first');
for k=1:length(atkval)
    output=mincost_flow(edgesfound(idx,:),[],atkval(k),1,0,def_inflows);
    pointimpact(i,k)=baseRev-output.total_income;
end
end

figure;
hold on;
pstyles={'-','--',':','-.','--'};
for i=1:2
    idx=find(edgeImpact==notmp(i,2),1,'first');
plot((atkval(1:end))*100,fliplr(pointimpact(i,:)/1000),pstyles{i},'linewidth',2.5);
end
hold off;
xh=xlabel('Capacity Reduction (%)');
yh=ylabel('Change in Impact per % Reduction (k$/hr)');
lh=legend('Square','Circle');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
ylim([0 100]);
%xlim([0 100]);
grid on;

figure;
plot((1-atkval)*100,magimpact/1000,'.-');
xlabel('Capacity Reduction (%)');
ylabel('Impact (k$/hr)');
xlim([40 100]);
grid on;

figure;
hold on;
pstyles={'-','--',':','-.','--'};
for i=2:5
    idx=find(edgeImpact==vals(i),1,'first');
plot((atkval(1:end))*100*opt_capacity(idx)/1e6,[0 diff(fliplr(magimpact(i,:)/1000))],pstyles{i-1},'linewidth',2.5);
end
hold off;
xlabel('Capacity Reduction (GW)');
ylabel('Change in Impact per additional GW Reduction (k$/hr)');
%xlim([0 100]);
grid on;

figure;
hold on;
pstyles={'-','--',':','-.','--'};
for i=2:5
    idx=find(edgeImpact==vals(i),1,'first');
plot((atkval(1:end))*100,[0 diff(fliplr(magimpact(i,:)/1000))],pstyles{i-1},'linewidth',2.5);
end
hold off;
xh=xlabel('Capacity Reduction (%)');
yh=ylabel('Change in Impact per Additional % Reduction (k$/hr)');
xlim([0 100]);
ylim([0 5]);
set(gca,'FontSize',12,'FontWeight','bold');
set(xh,'FontSize',12,'FontWeight','bold');
set(yh,'FontSize',12,'FontWeight','bold');
grid on;

% figure
% [haxes,hline1,hline2] = plotyy((1-atkval)*100,magimpact/1000,(1-atkval(1:end-1))*100,-1*diff(fliplr(magimpact/1000)),'plot','plot');
% ylabel(haxes(1),'Impact (k$/hr)') % label left y-axis
% ylabel(haxes(2),'Change in Impact per % Reduction (k$/hr)') % label right y-axis
% xlabel(haxes(2),'Capacity Reduction (%)') % label x-axis
% set(hline1,'LineStyle','.-');
% set(hline2,'LineStyle','*-','LineWidth',2);
% grid(haxes(1),'on');
% xlim(haxes(2),[40 100]);





%%%%%Experiment 1

%System Welfare Difference
sysdiff=baseRev-ind_baseRev;

idxlist=1:length(edgeImpact);
x=[ind_edgeImpact edgeImpact];
idxlist(all(x==0,2))=[];
x(all(x==0,2),:)=[];
z=sum(x,2);
[y,idx]=sort(z,'descend');
xp=x(idx,:)
idxlist=idxlist(idx);
%xp(all(xp<y(10),2),:)=[];
xp=xp/1000;
[xp,idx]=unique(xp,'rows');
idxlist=idxlist(idx);
xp2=xp(end-10:end,:);
%xp2=xp2(10:1,:);
bar(fliplr(xp),'grouped');
%x(:,1)=x(:,1)-x(:,2);
xp2=fliplr(xp2);
idxlist=fliplr(idxlist);
%xp2(:,1)=xp2(:,1)-xp2(:,2);
%xp2=xp2(end:1,:);
f1=figure;
z=sum(xp2,2);
[y,idx]=sort(z,'descend');
xp2=xp2(idx,:);
idxlist=idxlist(idx);
xid=1:10;
idxlist=fliplr(idxlist);
edgelist=edgesfound(idxlist,:);
namesrevidx(edgelist)
bar(xid,xp2(1:10,:),'grouped');
%set(gca,'XTick',[])
xlim([0 11]);
xh=xlabel('Edges');
yh=ylabel('Impact (k$/hr)');
lh=legend('Single Actor','Dual Actors')
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
applyhatch_pluscolor(f1,'/x');
diffImpact=[ind_edgeImpact_gas(idxlist) ind_edgeImpact_elec(idxlist)];
bar(diffImpact(1:10,:),'stacked');




%%%%%Experiment 2
ind_edgeImpact;
ind_edgeShortage;
impact=ind_edgeImpact(ind_edgeShortage>0);
shortage=ind_edgeShortage(ind_edgeShortage>0);

x=[impact shortage];
x(:,1)=x(:,1)/mean(x(:,1));
x(:,2)=x(:,2)/mean(x(:,2));
diffval=abs(x(:,1)-x(:,2));
%cmpv=median(diffval);
%x(diffval<cmpv,:)=[];
figure;
z=sum(x,2);
[y,idx]=sort(z,'descend');
x=x(idx,:);
xlb=1:size(x,1);
f1=figure;
bar(xlb,x,'grouped');
%set(gca,'XTick',[])
set(gca,'YTick',[])
xh=xlabel('Edges');
yh=ylabel('Normalized Impact');
lh=legend('Financial','Shortage');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
applyhatch_pluscolor(f1,'/x');