%Paul Wood
%pwood@isi.edu , pwood@purdue.edu 2014
%This defines the gas components of the graph
%See the last few lines for visualization

%Import the constants
constants;

%Define Arrays

%Capacity Array - Also Adjacenty Matrix when value > 0 taken
gas_capacity=zeros(nNodes,nNodes);
%Loss in Transmit
gas_loss=zeros(nNodes,nNodes);
%Revenue per unit flow
gas_revenue=zeros(nNodes,nNodes);
%Static Demand (non-elec)
gas_load=zeros(nNodes,nNodes);
g_demand=zeros(nNodes,1);

%Links, shown as symmetric directional
gas_capacity(WA,ID)=2974;
gas_capacity(ID,WA)=2974;

gas_capacity(ID,OR)=910;
gas_capacity(OR,ID)=910;

gas_capacity(ID,NV)=158;
gas_capacity(NV,ID)=158;

gas_capacity(WA,OR)=5198;
gas_capacity(OR,WA)=5198;

gas_capacity(OR,NV)=1500;
gas_capacity(NV,OR)=1500;

gas_capacity(CA,OR)=2391;
gas_capacity(OR,CA)=2391;

gas_capacity(CA,NV)=1940;
gas_capacity(NV,CA)=1940;

gas_capacity(CA,AZ)=6382;
gas_capacity(AZ,CA)=6382;

gas_capacity(NV,AZ)=294;
gas_capacity(AZ,NV)=294;

%Imports/Local Production
gas_capacity(WAGI,WA)=1781;
gas_capacity(IDGI,ID)=3278;
gas_capacity(NVGI,NV)=3945;
gas_capacity(AZGI,AZ)=5429;
gas_capacity(ORGI,OR)=591;
gas_capacity(CAGI,CA)=427;
g_demand(WAGI)=1781;
g_demand(IDGI)=3278;
g_demand(NVGI)=3945;
g_demand(AZGI)=5429;
g_demand(ORGI)=591;
g_demand(CAGI)=427;
%gas_capacity(WA,WAGI)=1781;
%gas_capacity(ID,IDGI)=3278;
%gas_capacity(NV,NVGI)=3945;
%gas_capacity(AZ,AZGI)=5429;
%gas_capacity(OR,ORGI)=591;
%gas_capacity(CA,CAGI)=427;

%Capacity for gas-elect based on maximum gas-generation capacity
gas_capacity(AZ,GASGENAZ)=2450.40450555664;
gas_capacity(CA,GASGENCA)=7132.34907639465;
gas_capacity(ID,GASGENID)=188.9841659604;
gas_capacity(OR,GASGENOR)=504.660584664618;
gas_capacity(NV,GASGENNV)=1293.97124733836;
gas_capacity(WA,GASGENWA)=723.784179445346;

%Revenue for delivery in dollars per MMBtu
gas_revenue(AZ,GASGENAZ)=3.43;
gas_revenue(CA,GASGENCA)=3.56;
gas_revenue(ID,GASGENID)=3.25;
gas_revenue(OR,GASGENOR)=3.04;
gas_revenue(NV,GASGENNV)=3.39;
gas_revenue(WA,GASGENWA)=4.07;
%Costs to prevent free gas flow
gas_profit_scale=0.75;
gas_revenue(WAGI,WA)=-gas_revenue(WA,GASGENWA)*gas_profit_scale;
gas_revenue(IDGI,ID)=-gas_revenue(ID,GASGENID)*gas_profit_scale;
gas_revenue(NVGI,NV)=-gas_revenue(NV,GASGENNV)*gas_profit_scale;
gas_revenue(AZGI,AZ)=-gas_revenue(AZ,GASGENAZ)*gas_profit_scale;
gas_revenue(ORGI,OR)=-gas_revenue(OR,GASGENOR)*gas_profit_scale;
gas_revenue(CAGI,CA)=-gas_revenue(CA,GASGENCA)*gas_profit_scale;

%Load for Non-Elec
gas_load(AZ,AZGC)=284.743466395548;
gas_load(CA,CAGC)=4241.21369863014;
gas_load(ID,IDGC)=206.989268514555;
gas_load(OR,ORGC)=368.834535530822;
gas_load(NV,NVGC)=227.178133026541;
gas_load(WA,WAGC)=605.597153253425;
%Retail SCale
retail_scale=1.15;
gas_revenue(AZ,AZGC)=3.43*retail_scale;
gas_revenue(CA,CAGC)=3.56*retail_scale;
gas_revenue(ID,IDGC)=3.25*retail_scale;
gas_revenue(OR,ORGC)=3.04*retail_scale;
gas_revenue(NV,NVGC)=3.39*retail_scale;
gas_revenue(WA,WAGC)=4.07*retail_scale;
g_demand(AZGC)=-284.743466395548;
g_demand(CAGC)=-4241.21369863014;
g_demand(IDGC)=-206.989268514555;
g_demand(ORGC)=-368.834535530822;
g_demand(NVGC)=-227.178133026541;
g_demand(WAGC)=-605.597153253425;
g_demand=g_demand*1.2;

gas_capacity=gas_capacity+gas_load*10;


%Gas Transmit Losses
gas_loss(AZ,AZ)=0;
gas_loss(CA,AZ)=1.75;
gas_loss(ID,AZ)=0;
gas_loss(OR,AZ)=0;
gas_loss(NV,AZ)=1.75;
gas_loss(WA,AZ)=0;
gas_loss(AZ,CA)=1.75;
gas_loss(CA,CA)=0;
gas_loss(ID,CA)=0;
gas_loss(OR,CA)=1.75;
gas_loss(NV,CA)=0.75;
gas_loss(WA,CA)=0;
gas_loss(AZ,ID)=0;
gas_loss(CA,ID)=0;
gas_loss(ID,ID)=0;
gas_loss(OR,ID)=1.1;
gas_loss(NV,ID)=1.35;
gas_loss(WA,ID)=1.25;
gas_loss(AZ,OR)=0;
gas_loss(CA,OR)=1.75;
gas_loss(ID,OR)=1.1;
gas_loss(OR,OR)=0;
gas_loss(NV,OR)=1.35;
gas_loss(WA,OR)=1;
gas_loss(AZ,NV)=1.75;
gas_loss(CA,NV)=0.75;
gas_loss(ID,NV)=1.35;
gas_loss(OR,NV)=1.35;
gas_loss(NV,NV)=0;
gas_loss(WA,NV)=0;
gas_loss(AZ,WA)=0;
gas_loss(CA,WA)=0;
gas_loss(ID,WA)=1.25;
gas_loss(OR,WA)=1;
gas_loss(NV,WA)=0;
gas_loss(WA,WA)=0;

%Adjacency Matrix
gas_adj=gas_capacity+gas_load;
gas_adj(gas_adj>0)=1;
% 
% 
% %Some visualization
% %capgraph=round((gas_capacity+gas_load)/100)/10;
% %capgraph=round((gas_loss)*100)/100;
% capgraph=round((gas_revenue)*100)/100;
% 
%bg2=create_biograph_obj(capgraph);
% view(bg2);
   

