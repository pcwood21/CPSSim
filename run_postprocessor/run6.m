%Load run 4 data

%run6_data
noise_attacker_vals=run6_input.v1;
nNoisea=length(noise_attacker_vals);
noise_defender_vals=run6_input.v2;
nNoised=length(noise_defender_vals);
nOwner_vals=run6_input.v3;
nOwnersVals=length(nOwner_vals);
mc_num_vals=run6_input.v4;
mc_num=length(mc_num_vals);

output=run6_data{1,1,1,1};
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

%x=size(run6_data);
%x=x(1)*x(2)*x(3)*x(4);
unsuccess=zeros(nNoisea,nNoised,nOwnersVals,mc_num);

for i=1:nNoisea
    for j=1:nNoised
        for k=1:nOwnersVals
            max_defense_cost=total_max_defense_cost/nOwner_vals(k);
            parfor l=1:mc_num
                output=run6_data{i,j,k,l};
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


%Experiment 3a
figure
hold all;
plot_param=risk_mitigated;
%plot_param=defense_roi;
plot(noise_defender_vals,squeeze(plot_param(1,:,1)),'-k','linewidth',2);
plot(noise_defender_vals,squeeze(plot_param(1,:,2)),'--k','linewidth',2);
plot(noise_defender_vals,squeeze(plot_param(1,:,3)),'-.k','linewidth',2);
plot(noise_defender_vals,squeeze(plot_param(1,:,4)),':k','linewidth',2);
%plot(noise_defender_vals,squeeze(mean(risk_mitigated(1,:,:),3)),'-b','linewidth',3);
%plot(noise_defender_vals,squeeze(mean(risk_mitigated_c(1,:,:),3)),'--b','linewidth',3);
xh=xlabel('\sigma Noise for Defender');
yh=ylabel('Reduction in Impact of Attack');
lh=legend('2-Actors','4-Actors','6-Actors','12-Actors');%,'16-Actors');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
%xlim([1 maxNTarget]);
hold off;

%Experiment 3b
figure
hold all;
plot(noise_defender_vals,squeeze(risk_mitigated(1,:,3)),'-k','linewidth',2);
plot(noise_defender_vals,squeeze(risk_mitigated_c(1,:,3)),'--k','linewidth',2);
xh=xlabel('\sigma Noise for Defender');
yh=ylabel('Reduction in Impact of Attack');
lh=legend('W/O Collab.','W/ Collab.');%,'16-Actors');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
%xlim([1 maxNTarget]);
hold off;
