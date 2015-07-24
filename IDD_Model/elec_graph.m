%Paul Wood
%pwood@isi.edu , pwood@purdue.edu 2014
%This file defines the components of the electric graph
%See the last few lines to visualize this component

constants;

%Capacity/Adjacency
elec_capacity=zeros(nNodes,nNodes);
%Loss in Transmit
elec_loss=zeros(nNodes,nNodes);
%Generation Costs
elec_gen_cost=zeros(nNodes,nNodes);
%Customer Loads
elec_load=zeros(nNodes,nNodes);
%Electric Revnues
elec_revenue=zeros(nNodes,nNodes);
e_demand=zeros(nNodes,1);

elec_capacity(EWA,EID)=2000;
elec_capacity(EID,EWA)=2000;
elec_loss(EWA,EID)=1.9;
elec_loss(EID,EWA)=1.9;

elec_capacity(EWA,EOR)=7000;
elec_capacity(EOR,EWA)=7000;
elec_loss(EWA,EOR)=1.5;
elec_loss(EOR,EWA)=1.5;

elec_capacity(EOR,EID)=2000;
elec_capacity(EID,EOR)=2000;
elec_loss(EOR,EID)=1.75;
elec_loss(EID,EOR)=1.75;

elec_capacity(EOR,ENV)=3000;
elec_capacity(ENV,EOR)=3000;
elec_loss(EOR,ENV)=2.00;
elec_loss(ENV,EOR)=2.00;

elec_capacity(EID,ENV)=750;
elec_capacity(ENV,EID)=750;
elec_loss(ENV,EID)=2.00;
elec_loss(EID,ENV)=2.00;

elec_capacity(EOR,ECA)=1000;
elec_capacity(ECA,EOR)=1000;
elec_loss(EOR,ECA)=2.75;
elec_loss(ECA,EOR)=2.75;

elec_capacity(ENV,ECA)=11400;
elec_capacity(ECA,ENV)=11400;
elec_loss(ENV,ECA)=1.15;
elec_loss(ECA,ENV)=1.15;

elec_capacity(ECA,EAZ)=4000;
elec_capacity(EAZ,ECA)=4000;
elec_loss(ECA,EAZ)=2.75;
elec_loss(EAZ,ECA)=2.75;

elec_capacity(ENV,EAZ)=4000;
elec_capacity(EAZ,ENV)=4000;
elec_loss(ENV,EAZ)=2.75;
elec_loss(EAZ,ENV)=2.75;

elec_capacity(AZEI,EAZ)=1500;
elec_capacity(NVEI,ENV)=3150;
elec_capacity(IDEI,EID)=3500;

%Generating Capacities
elec_capacity(COALGENAZ,EAZ)=6157;
elec_capacity(COALGENCA,ECA)=351;
elec_capacity(COALGENID,EID)=17;
elec_capacity(COALGENOR,EOR)=585;
elec_capacity(COALGENNV,ENV)=1293;
elec_capacity(COALGENWA,EWA)=1340;
elec_capacity(HYDRGENAZ,EAZ)=2720;
elec_capacity(HYDRGENCA,ECA)=10146;
elec_capacity(HYDRGENID,EID)=2703;
elec_capacity(HYDRGENOR,EOR)=8455;
elec_capacity(HYDRGENNV,ENV)=1051;
elec_capacity(HYDRGENWA,EWA)=21115;
elec_capacity(GASGENAZ,EAZ)=13557;
elec_capacity(GASGENCA,ECA)=41576;
elec_capacity(GASGENID,EID)=1111;
elec_capacity(GASGENOR,EOR)=3010;
elec_capacity(GASGENNV,ENV)=7255;
elec_capacity(GASGENWA,EWA)=3795;
elec_capacity(NUCGENAZ,EAZ)=3937;
elec_capacity(NUCGENCA,ECA)=4390;
elec_capacity(NUCGENID,EID)=0;
elec_capacity(NUCGENOR,EOR)=0;
elec_capacity(NUCGENNV,ENV)=0;
elec_capacity(NUCGENWA,EWA)=1132;
elec_capacity(RNWGENAZ,EAZ)=870;
elec_capacity(RNWGENCA,ECA)=6683;
elec_capacity(RNWGENID,EID)=963;
elec_capacity(RNWGENOR,EOR)=3163;
elec_capacity(RNWGENNV,ENV)=477;
elec_capacity(RNWGENWA,EWA)=2807;
elec_capacity(OTRGENAZ,EAZ)=346;
elec_capacity(OTRGENCA,ECA)=8183;
elec_capacity(OTRGENID,EID)=117;
elec_capacity(OTRGENOR,EOR)=331;
elec_capacity(OTRGENNV,ENV)=400;
elec_capacity(OTRGENWA,EWA)=721;
e_demand(COALGENAZ)=6157;
e_demand(COALGENCA)=351;
e_demand(COALGENID)=17;
e_demand(COALGENOR)=585;
e_demand(COALGENNV)=1293;
e_demand(COALGENWA)=1340;
e_demand(HYDRGENAZ)=2720;
e_demand(HYDRGENCA)=10146;
e_demand(HYDRGENID)=2703;
e_demand(HYDRGENOR)=8455;
e_demand(HYDRGENNV)=1051;
e_demand(HYDRGENWA)=21115;
e_demand(NUCGENAZ)=3937;
e_demand(NUCGENCA)=4390;
e_demand(NUCGENID)=0;
e_demand(NUCGENOR)=0;
e_demand(NUCGENNV)=0;
e_demand(NUCGENWA)=1132;
e_demand(RNWGENAZ)=870;
e_demand(RNWGENCA)=6683;
e_demand(RNWGENID)=963;
e_demand(RNWGENOR)=3163;
e_demand(RNWGENNV)=477;
e_demand(RNWGENWA)=2807;
e_demand(OTRGENAZ)=346;
e_demand(OTRGENCA)=8183;
e_demand(OTRGENID)=117;
e_demand(OTRGENOR)=331;
e_demand(OTRGENNV)=400;
e_demand(OTRGENWA)=721;
e_demand=e_demand*0.75;

%Costs per kWh in cents
elec_gen_cost(COALGENAZ,EAZ)=2.55508680992928;
elec_gen_cost(COALGENCA,ECA)=3.88741866022264;
elec_gen_cost(COALGENID,EID)=3.21600733409055;
elec_gen_cost(COALGENOR,EOR)=2.35576157248382;
elec_gen_cost(COALGENNV,ENV)=3.06913610649916;
elec_gen_cost(COALGENWA,EWA)=2.77539365131637;
elec_gen_cost(HYDRGENAZ,EAZ)=0.671;
elec_gen_cost(HYDRGENCA,ECA)=0.671;
elec_gen_cost(HYDRGENID,EID)=0.671;
elec_gen_cost(HYDRGENOR,EOR)=0.671;
elec_gen_cost(HYDRGENNV,ENV)=0.671;
elec_gen_cost(HYDRGENWA,EWA)=0.671;
elec_gen_cost(GASGENAZ,EAZ)=2.88915100204079;
elec_gen_cost(GASGENCA,ECA)=2.84971564882531;
elec_gen_cost(GASGENID,EID)=2.60293925099853;
elec_gen_cost(GASGENOR,EOR)=2.41900208526769;
elec_gen_cost(GASGENNV,ENV)=2.82374869817903;
elec_gen_cost(GASGENWA,EWA)=3.55537044155884;
elec_gen_cost(NUCGENAZ,EAZ)=1.858;
elec_gen_cost(NUCGENCA,ECA)=1.858;
elec_gen_cost(NUCGENID,EID)=1.858;
elec_gen_cost(NUCGENOR,EOR)=1.858;
elec_gen_cost(NUCGENNV,ENV)=1.858;
elec_gen_cost(NUCGENWA,EWA)=1.858;
elec_gen_cost(RNWGENAZ,EAZ)=0.8;
elec_gen_cost(RNWGENCA,ECA)=0.8;
elec_gen_cost(RNWGENID,EID)=0.8;
elec_gen_cost(RNWGENOR,EOR)=0.8;
elec_gen_cost(RNWGENNV,ENV)=0.8;
elec_gen_cost(RNWGENWA,EWA)=0.8;
elec_gen_cost(OTRGENAZ,EAZ)=7.3575;
elec_gen_cost(OTRGENCA,ECA)=10.1475;
elec_gen_cost(OTRGENID,EID)=5.19;
elec_gen_cost(OTRGENOR,EOR)=6.1575;
elec_gen_cost(OTRGENNV,ENV)=6.7125;
elec_gen_cost(OTRGENWA,EWA)=5.205;

elec_gen_cost(AZEI,EAZ)=elec_gen_cost(OTRGENAZ,EAZ);
elec_gen_cost(NVEI,ENV)=elec_gen_cost(OTRGENNV,ENV);
elec_gen_cost(IDEI,EID)=elec_gen_cost(OTRGENID,EID);

%Gas Conversion Efficiency
elec_loss(GASGENAZ,EAZ)=(1-0.4424499957791)*100;
elec_loss(GASGENCA,ECA)=(1-0.466174479755795)*100;
elec_loss(GASGENID,EID)=(1-0.470139804281236)*100;
elec_loss(GASGENOR,EOR)=(1-0.476985844488376)*100;
elec_loss(GASGENNV,ENV)=(1-0.448385099738741)*100;
elec_loss(GASGENWA,EWA)=(1-0.419315653896926)*100;

%Loads in MW, Avg Daily
avg_to_peak=1.65;
elec_load(EAZ,AZEC)=8568.8747716895*avg_to_peak;
elec_load(ECA,CAEC)=29627.6299086758*avg_to_peak;
elec_load(EID,IDEC)=2706.83321917808*avg_to_peak;
elec_load(EOR,OREC)=5329.77808219178*avg_to_peak;
elec_load(ENV,NVEC)=4015.97237442922*avg_to_peak;
elec_load(EWA,WAEC)=10540.6896118721*avg_to_peak;
e_demand(AZEC)=-8568.8747716895*avg_to_peak;
e_demand(CAEC)=-29627.6299086758*avg_to_peak;
e_demand(IDEC)=-2706.83321917808*avg_to_peak;
e_demand(OREC)=-5329.77808219178*avg_to_peak;
e_demand(NVEC)=-4015.97237442922*avg_to_peak;
e_demand(WAEC)=-10540.6896118721*avg_to_peak;
elec_capacity=elec_capacity+elec_load*10;

elec_revenue(EAZ,AZEC)=9.81;
elec_revenue(ECA,CAEC)=13.53;
elec_revenue(EID,IDEC)=6.92;
elec_revenue(EOR,OREC)=8.21;
elec_revenue(ENV,NVEC)=8.95;
elec_revenue(EWA,WAEC)=6.94;



elec_adj=elec_capacity+elec_load;
elec_adj(elec_adj>0)=1;


%Uncomment and call to visualize the electric graph
%capgraph=round((elec_capacity+elec_load)/100)/10;
%capgraph=round((-elec_gen_cost+elec_revenue)*100)/100;
%% For testing, leave commented
%% capgraph(EAZ,:)=0;
%% capgraph(EID,:)=0;
%% capgraph(EOR,:)=0;
%% capgraph(EWA,:)=0;
%% capgraph(ENV,:)=0;
%% capgraph(:,EAZ)=0;
%% capgraph(:,EID)=0;
%% capgraph(:,EOR)=0;
%% capgraph(:,EWA)=0;
%% capgraph(:,ENV)=0;
% 
%bg2=create_biograph_obj(capgraph);
% view(bg2);