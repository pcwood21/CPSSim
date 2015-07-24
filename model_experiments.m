clear all;
clc;

%Import the NG model as edges, capacity, cost, and loss ground truth
[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
%Convert these parameters to a partial linear optimization problem
[linprog_params]=graph_to_optimization(edges,capacity,cost,loss,[]);
%Optimize the flows in the system
[total_cost,flows]=optimize_cost(linprog_params);
linprog_params.x0=flows;

base_cost=total_cost;
base_flows=flows;
nEdges=length(edges);

%Create edge ownership assignments
single_ownership=ones(nEdges,1);

gaselec_ownership=zeros(nEdges,1);
gaselec_ownership(extras.mapped_is_gas==1)=1;
gaselec_ownership(extras.mapped_is_elec==1)=2;

nOwners=16;
random_ownership=randi([1,nOwners],[nEdges,1]);

%matlabpool('open',8);
%matlabpool('close');
impact_matrix_single=create_impact_matrix(linprog_params,single_ownership,1);
impact_matrix_random=create_impact_matrix(linprog_params,random_ownership,1);
impact_matrix_gaselec=create_impact_matrix(linprog_params,gaselec_ownership,1);



%Create a set of impact matricies
%{
rownership=zeros(mc_num,nEdges);
random_impact_collection=cell(mc_num,1);
for i=1:mc_num
    rand_own=randi([1,nOwners],[nEdges,1]);
    tlpp=add_noise_lpp(linprog_params,0.25);
    [~,tflows]=optimize_cost(tlpp);
    tlpp.x0=tflows;
    timp_random=create_impact_matrix(tlpp,rand_own,1);
    rownership(i,:)=rand_own;
    random_impact_collection{i}=timp_random;
end
%}


%Collect data for noise levels
noise_levels=[0.05 0.10 0.15 0.25 0.35];
nNoise=length(noise_levels);
nRandOwner=5;
mc_num=10;
noise_owners=cell(nRandOwner);
noise_impact=cell(nRandOwner,nNoise,mc_num);
for i=1:nRandOwner
    rand_own=randi([1,nOwners],[nEdges,1]);
    noise_owners{i}=rand_own;
    for j=1:nNoise
        noise_amt=noise_levels(j);
        for k=1:mc_num
            tlpp=add_noise_lpp(linprog_params,noise_amt);
            [~,tflows]=optimize_cost(tlpp);
            tlpp.x0=tflows;
            timp_random=create_impact_matrix(tlpp,rand_own,1);
            noise_impact{i,j,k}=timp_random;
        end
    end
end

%Find value of attack strategy
noise_atk_value=zeros(nNoise,nRandOwner,mc_num);
noise_atk_targets=zeros(nNoise,nRandOwner,mc_num,nEdges);
for i=1:nOwnerLevels
    ownership_matrix=noise_owners{i};
    truth_impact=create_impact_matrix(linprog_params,ownership_matrix,1);
    for j=1:nNoise
        for k=1:mc_num
            impact_matrix=noise_impact{i,j,k};
            %owner_matrix=owner_owners{i,j};
            [atk_owners,atk_targets,~]=attacker_strategy(impact_matrix);
            atk_values=truth_impact(:,atk_owners);
            atk_value=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
            noise_atk_value(i,j,k)=atk_value;
            row=zeros(1,nEdges);
            row(atk_targets)=1;
            noise_atk_targets(i,j,k,:)=row';
        end
    end
end


%Collect data for owner levels
owner_levels=[1 2 4 6 8];
nOwnerLevels=length(owner_levels);
mc_num=5;
nRandOwner=3;
noise_amt=0.1;
owner_impact=cell(nOwnerLevels,nRandOwner,mc_num);
owner_owners=cell(nOwnerLevels,nRandOwner);
for i=1:nOwnerLevels
    nOwners=owner_levels(i);
    for j=1:nRandOwner
        rand_own=randi([1,nOwners],[nEdges,1]);
        owner_owners{i,j}=rand_own;
        for k=1:mc_num
            tlpp=add_noise_lpp(linprog_params,noise_amt);
            [~,tflows]=optimize_cost(tlpp);
            tlpp.x0=tflows;
            timp_random=create_impact_matrix(tlpp,rand_own,1);
            owner_impact{i,j,k}=timp_random;
        end
    end
end

%Find value of attack strategy
mc_num=5;
owner_atk_value=zeros(nOwnerLevels,nRandOwner,mc_num);
owner_atk_targets=zeros(nOwnerLevels,nRandOwner,mc_num,nEdges);
for i=1:nOwnerLevels
    for j=1:nRandOwner
        ownership_matrix=owner_owners{i,j};
        truth_impact=create_impact_matrix(linprog_params,ownership_matrix,1);
        for k=1:mc_num
            impact_matrix=owner_impact{i,j,k};
            %owner_matrix=owner_owners{i,j};
            [atk_owners,atk_targets,~]=attacker_strategy(impact_matrix);
            atk_values=truth_impact(:,atk_owners);
            atk_value=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
            owner_atk_value(i,j,k)=atk_value;
            row=zeros(nEdges,1);
            row(atk_targets)=1;
            owner_atk_targets(i,j,k,:)=row';
        end
    end
end


%Plot value of attack vs owners and noise
vals=mean(owner_atk_value,3);
vals=max(vals,[],2);

            

%{
mc_num=30;
atk_val=zeros(mc_num,1);
atk_targets=zeros(mc_num,nEdges);
for i=1:mc_num
    tlpp=add_noise_lpp(linprog_params,0.25);
    timp_random=create_impact_matrix(tlpp,random_ownership,1);
    [~,ttargets,tprofits]=attacker_strategy(timp_random);
    atk_val(i)=tprofits;
    row=zeros(1,nEdges);
    row(ttargets)=1;
    atk_targets(i,:)=row;
    i
end
%}


