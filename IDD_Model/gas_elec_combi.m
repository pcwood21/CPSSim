%This merges the two graphs into the interconnected system
%The first section normalizes the units
%The second section connects the components
%The lower half is for visualization


elec_graph;
gas_graph;

%Remove these cost/revenues for combined model
gas_revenue(AZ,GASGENAZ)=0;
gas_revenue(CA,GASGENCA)=0;
gas_revenue(ID,GASGENID)=0;
gas_revenue(OR,GASGENOR)=0;
gas_revenue(NV,GASGENNV)=0;
gas_revenue(WA,GASGENWA)=0;
elec_gen_cost(GASGENAZ,EAZ)=0;
elec_gen_cost(GASGENCA,ECA)=0;
elec_gen_cost(GASGENID,EID)=0;
elec_gen_cost(GASGENOR,EOR)=0;
elec_gen_cost(GASGENNV,ENV)=0;
elec_gen_cost(GASGENWA,EWA)=0;

%Standardize Losses as Decimal
elec_loss=elec_loss/100;
gas_loss=gas_loss/100;

%Standardize Capacities
gas_capacity=gas_capacity*1024;
%Now in BTU, estimated
gas_capacity=gas_capacity*1055870000;
%Now in Joules per Day
gas_capacity=gas_capacity/(24*60*60);
%Now in Watts
gas_load=gas_load*1024*1055870000/(24*60*60);
g_demand=g_demand*1024*1055870000/(24*60*60);

%Revenue in dollars per MMBtu million btu
gas_revenue=gas_revenue/293071/(60*60);
%Now in dollars per Watt-second
gas_revenue=gas_revenue*1e6;

%Starts in MW
elec_capacity=elec_capacity*1e6;
elec_load=elec_load*1e6;
e_demand=e_demand*1e6;
%Now in Watts

%Starts in cents/kWh
elec_gen_cost=elec_gen_cost/(60*60)/100;
elec_revenue=elec_revenue/(60*60)/100;
%Now in dollars per kWatt-second
elec_gen_cost=elec_gen_cost*1e3; %MW
elec_revenue=elec_revenue*1e3; %MW

%Generation Capacity Adjustment
%Based on EIA regional capacity 
%elec_capacity=elec_capacity*0.75;


%Now that everything is normalized, construct the combined graph

c_capacity=gas_capacity+elec_capacity;
c_capacity=c_capacity/1e6; %MJoule
c_capacity=round(c_capacity);
c_loss=gas_loss+elec_loss;
c_revenue=gas_revenue+elec_revenue;
c_load=gas_load+elec_load;
c_load=c_load/1e6; %MW
c_load=round(c_load);
c_adj=elec_adj+gas_adj;
c_demand=e_demand+g_demand;
c_demand=c_demand/1e6;
c_demand=round(c_demand);
c_supply=c_demand;
c_supply(c_supply<0)=0;

c_demand=c_demand-c_supply;
c_cost=elec_gen_cost-c_revenue;



%Set me to 1 to view the graph, but leave at 0 for running studies
dispplot=0;
if dispplot
%Square up the matrix for display only
c_capcnt=c_capacity;
c_capcnt(c_capcnt>0)=1;
ctmp=c_capacity;
ctmp=tril(ctmp,-1)'+ctmp;
c_capcnt=tril(c_capcnt,-1)'+c_capcnt;
ctmp(c_capcnt>1)=ctmp(c_capcnt>1)/2;

bgcomb=triu((ctmp));
bgcomb=round(bgcomb/100)/10;
bg=biograph(bgcomb,nodeNames,'ShowWeights','on','ShowArrows','off');
[s, c]=conncomp(bg,'Weak','true');
x=1:nNodes;
delnodes=[];
for i=1:length(c);
    if sum(c==c(i)) == 1
        delnodes=[delnodes x(c==c(i))];
    end
end

tNodeNames=nodeNames;
tNodeNames(delnodes,:)=[];
tcapgraph=bgcomb;
tcapgraph(delnodes,:)=[];
tcapgraph(:,delnodes)=[];
bg2=biograph(tcapgraph,tNodeNames,'ShowWeights','on','ShowArrows','off','LayoutType','hierarchical');
view(bg2);

c_capcnt=c_cost;
c_capcnt(c_capcnt>0)=1;
ctmp=c_cost;
ctmp=tril(ctmp,-1)'+ctmp;
c_capcnt=tril(c_capcnt,-1)'+c_capcnt;
ctmp(c_capcnt>1)=ctmp(c_capcnt>1)/2;

bgcomb=triu((ctmp));
bgcomb=round(bgcomb*60*60*10)/10;
bg=biograph(bgcomb,nodeNames,'ShowWeights','on','ShowArrows','off');
[s, c]=conncomp(bg,'Weak','true');
x=1:nNodes;
delnodes=[];
for i=1:length(c);
    if sum(c==c(i)) == 1
        delnodes=[delnodes x(c==c(i))];
    end
end

tNodeNames=nodeNames;
tNodeNames(delnodes,:)=[];
tcapgraph=bgcomb;
tcapgraph(delnodes,:)=[];
tcapgraph(:,delnodes)=[];
bg2=biograph(tcapgraph,tNodeNames,'ShowWeights','on','ShowArrows','off','LayoutType','hierarchical');
view(bg2);


c_capcnt=c_loss;
c_capcnt(c_capcnt>0)=1;
ctmp=c_loss;
ctmp=tril(ctmp,-1)'+ctmp;
c_capcnt=tril(c_capcnt,-1)'+c_capcnt;
ctmp(c_capcnt>1)=ctmp(c_capcnt>1)/2;

bgcomb=triu((ctmp));
bgcomb=round(bgcomb*1000)/10;
bg=biograph(bgcomb,nodeNames,'ShowWeights','on','ShowArrows','off');
[s, c]=conncomp(bg,'Weak','true');
x=1:nNodes;
delnodes=[];
for i=1:length(c);
    if sum(c==c(i)) == 1
        delnodes=[delnodes x(c==c(i))];
    end
end

tNodeNames=nodeNames;
tNodeNames(delnodes,:)=[];
tcapgraph=bgcomb;
tcapgraph(delnodes,:)=[];
tcapgraph(:,delnodes)=[];
bg2=biograph(tcapgraph,tNodeNames,'ShowWeights','on','ShowArrows','off','LayoutType','hierarchical');
view(bg2);

end


