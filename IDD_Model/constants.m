%Paul Wood
%pwood@isi.edu , pwood@purdue.edu 2014
%Quick and dirty enumeration and naming scheme

%Define Indicies for Graph Array

%These are the gas hubs
WA=1;
OR=2;
CA=3;
AZ=4;
NV=5;
ID=6;
%These are gas generators
GASGENWA=7;
GASGENOR=8;
GASGENCA=9;
GASGENAZ=10;
GASGENNV=11;
GASGENID=12;
%These are electric hubs
EWA=13;
EOR=14;
ECA=15;
EAZ=16;
ENV=17;
EID=18;
%These are the gas customers
WAGC=19;
ORGC=20;
CAGC=21;
AZGC=22;
NVGC=23;
IDGC=24;
%Electric Customers
WAEC=25;
OREC=26;
CAEC=27;
AZEC=28;
NVEC=29;
IDEC=30;
%Gas Imports
WAGI=31;
ORGI=32;
CAGI=33;
AZGI=34;
NVGI=35;
IDGI=36;
%Electric Imports
WAEI=37;
OREI=38;
CAEI=39;
AZEI=40;
NVEI=41;
IDEI=42;
%Nuclear Generator
NUCGENWA=43;
NUCGENOR=44;
NUCGENCA=45;
NUCGENAZ=46;
NUCGENNV=47;
NUCGENID=48;
%Coal Generator
COALGENWA=49;
COALGENOR=50;
COALGENCA=51;
COALGENAZ=52;
COALGENNV=53;
COALGENID=54;
%Renewables
RNWGENWA=55;
RNWGENOR=56;
RNWGENCA=57;
RNWGENAZ=58;
RNWGENNV=59;
RNWGENID=60;
%Other (Expensive) Sources
OTRGENWA=61;
OTRGENOR=62;
OTRGENCA=63;
OTRGENAZ=64;
OTRGENNV=65;
OTRGENID=66;
%Hydroelectric generators
HYDRGENWA=67;
HYDRGENOR=68;
HYDRGENCA=69;
HYDRGENAZ=70;
HYDRGENNV=71;
HYDRGENID=72;


nNodes=72;
%This is deprecated list of names
nodeNames=[
    'GWA ';
'GOR ';
'GCA ';
'GAZ ';
'GNV ';
'GID ';
'GEN1';
'GEN2';
'GEN3';
'GEN4';
'GEN5';
'GEN6';
'EWA ';
'EOR ';
'ECA ';
'EAZ ';
'ENV ';
'EID ';
'WAGC';
'ORGC';
'CAGC';
'AZGC';
'NVGC';
'IDGC';
'WAEC';
'OREC';
'CAEC';
'AZEC';
'NVEC';
'IDEC';
'WAGI';
'ORGI';
'CAGI';
'AZGI';
'NVGI';
'IDGI';
'WAEI';
'OREI';
'CAEI';
'AZEI';
'NVEI';
'IDEI';
'NCWA';
'NCOR';
'NCCA';
'NCAZ';
'NCNV';
'NCID';
'CLWA';
'CLOR';
'CLCA';
'CLAZ';
'CLNV';
'CLID';
'RNWA';
'RNOR';
'RNCA';
'RNAZ';
'RNNV';
'RNID';
'OTWA';
'OTOR';
'OTCA';
'OTAZ';
'OTNV';
'OTID';
'HDWA';
'HDOR';
'HDCA';
'HDAZ';
'HDNV';
'HDID'
];

%This list, as a cell array, allows translation of node numbers into corresponding names
namesrevidx={'WA',...
'OR',...
'CA',...
'AZ',...
'NV',...
'ID',...
'GASGENWA',...
'GASGENOR',...
'GASGENCA',...
'GASGENAZ',...
'GASGENNV',...
'GASGENID',...
'EWA',...
'EOR',...
'ECA',...
'EAZ',...
'ENV',...
'EID',...
'WAGC',...
'ORGC',...
'CAGC',...
'AZGC',...
'NVGC',...
'IDGC',...
'WAEC',...
'OREC',...
'CAEC',...
'AZEC',...
'NVEC',...
'IDEC',...
'WAGI',...
'ORGI',...
'CAGI',...
'AZGI',...
'NVGI',...
'IDGI',...
'WAEI',...
'OREI',...
'CAEI',...
'AZEI',...
'NVEI',...
'IDEI',...
'NUCGENWA',...
'NUCGENOR',...
'NUCGENCA',...
'NUCGENAZ',...
'NUCGENNV',...
'NUCGENID',...
'COALGENWA',...
'COALGENOR',...
'COALGENCA',...
'COALGENAZ',...
'COALGENNV',...
'COALGENID',...
'RNWGENWA',...
'RNWGENOR',...
'RNWGENCA',...
'RNWGENAZ',...
'RNWGENNV',...
'RNWGENID',...
'OTRGENWA',...
'OTRGENOR',...
'OTRGENCA',...
'OTRGENAZ',...
'OTRGENNV',...
'OTRGENID',...
'HYDRGENWA',...
'HYDRGENOR',...
'HYDRGENCA',...
'HYDRGENAZ',...
'HYDRGENNV',...
'HYDRGENID'};