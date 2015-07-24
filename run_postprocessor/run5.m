%Load run 4 data

%run5_data
noise_attacker_vals=run5_input.v1;
nNoisea=length(noise_attacker_vals);
noise_defender_vals=run5_input.v2;
nNoised=length(noise_defender_vals);
nOwner_vals=run5_input.v3;
nOwnersVals=length(nOwner_vals);
mc_num_vals=run5_input.v4;
mc_num=length(mc_num_vals);

output=run5_data{1,1,1,1};
tmp=output.attack_targets{1};
nAssets=size(tmp,2);
unsuccess=[];

total_max_defense_cost=12;
nTargets=4;

%protection_cost_none_array=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
%protection_cost_full_array=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
%risk_mitigated_none_array=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
%risk_mitigated_full_array=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
protection_cost_array=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
risk_mitigated_array=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
protection_cost_array_c=zeros(nNoisea,nNoised,nOwnersVals,mc_num);
risk_mitigated_array_c=zeros(nNoisea,nNoised,nOwnersVals,mc_num);

%x=size(run5_data);
%x=x(1)*x(2)*x(3)*x(4);
unsuccess=zeros(nNoisea,nNoised,nOwnersVals,mc_num);

for i=1:nNoisea
    for j=1:nNoised
        for k=1:nOwnersVals
            max_defense_cost=total_max_defense_cost/nOwner_vals(k);
            parfor l=1:mc_num
                output=run5_data{i,j,k,l};
                if ~isfield(output,'impact_truth')
                    %unsuccess(i,j,k,l)=output;
                    continue;
                end
                
                nsubMc=length(output.attack_targets);
                attack_targets=zeros(nsubMc,nAssets);
                for m=1:nsubMc
                    tmp1=output.attack_targets{m};
                    tmp2=tmp1(nTargets,:);
                    attack_targets(m,:)=tmp2;
                end
                
                attack_freq=sum(attack_targets,1);
                target_atk_prob=squeeze(attack_freq/nsubMc);
                ownership=output.ownership;
                impact_matrix=output.defender_impact_matrix;
                target_defense_cost=ones(nAssets,1);
                truth_impact=output.impact_truth;
                tmp=truth_impact;
                tmp(tmp>0)=0;
                
                no_collaboration_matrix=zeros(size(impact_matrix,2),size(impact_matrix,2));
                full_collaboration_matrix=ones(size(impact_matrix,2),size(impact_matrix,2));
                
                [ protected_targets ,defense_cost, ~ ] = defender_strategy( impact_matrix,target_atk_prob,target_defense_cost,ownership,max_defense_cost,no_collaboration_matrix );
                [ protected_targets_c ,defense_cost_c, ~ ] = defender_strategy( impact_matrix,target_atk_prob,target_defense_cost,ownership,max_defense_cost,full_collaboration_matrix );
                
                t1=sum(tmp(protected_targets==1,:),2);
                t2=sum(tmp(protected_targets_c==1,:),2);
                risk_m=sum(t1.*target_atk_prob(protected_targets==1)');
                risk_m_c=sum(t2.*target_atk_prob(protected_targets_c==1)');
                
                protection_cost_array(i,j,k,l)=sum(defense_cost);
                protection_cost_array_c(i,j,k,l)=sum(defense_cost_c);
                risk_mitigated_array(i,j,k,l)=risk_m;
                risk_mitigated_array_c(i,j,k,l)=risk_m_c;
                
            end
        end
    end
end

return;


risk_mitigated=-1*median(risk_mitigated_array(:,:,:,:),4);
protection_cost=median(protection_cost_array(:,:,:,:),4);
defense_roi=risk_mitigated./protection_cost;
risk_mitigated_c=-1*median(risk_mitigated_array_c(:,:,:,:),4);
protection_cost_c=median(protection_cost_array_c(:,:,:,:),4);
defense_roi_c=risk_mitigated_c./protection_cost_c;


%Experiment 3c
f1=figure;
ydim=size(risk_mitigated,3);
yvals=zeros(ydim,2);
yvals(:,1)=-1*squeeze(mean(risk_mitigated_array(3,1,:,:),4));%risk_mitigated(1,1,:);
yvals(:,2)=-1*squeeze(mean(risk_mitigated_array_c(3,1,:,:),4));%risk_mitigated_c(1,1,:);
%yvals(:,1)=defense_roi(2,1,:);
%yvals(:,2)=defense_roi_c(2,1,:);
bar(1:ydim,yvals,'grouped');
xlabs={'2','4','6','12'};
set(gca,'XTick',[1 2 3 4]);
set(gca,'xticklabel',xlabs);
xh=xlabel('Num. of Actors');
yh=ylabel('Reduction in Impact of Attack');
lh=legend('W/O Collab.','W/ Collab.');%,'16-Actors');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
applyhatch_pluscolor(f1,'/x');

