
%Note: For Run 2, impact was inverted, and results nullified for attacker
%strategy

output=run3_data{1,1,1};
nEdges=size(output.impact_matrix,1);
nNoiseIdx=size(run3_data,1);
nNoiseVals=run3_input.v1;
nOwnerIdx=size(run3_data,2);
nOwnerVals=run3_input.v2;
nMcIdx=size(run3_data,3);
maxNTarget=20;
attack_value_array=zeros(nNoiseIdx,nOwnerIdx,maxNTarget,nMcIdx)*NaN;
attack_false_value_array=zeros(nNoiseIdx,nOwnerIdx,maxNTarget,nMcIdx)*NaN;
target_atk_prob=zeros(nNoiseIdx,nOwnerIdx,nEdges)*NaN;
max_target_impact=zeros(nNoiseIdx,nOwnerIdx,nMcIdx)*NaN;
min_target_impact=zeros(nNoiseIdx,nOwnerIdx,nMcIdx)*NaN;
total_gain_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx)*NaN;
total_loss_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx)*NaN;
impact_stddev_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx)*NaN;
unsuccess=[];
for i=1:nNoiseIdx
    for j=1:nOwnerIdx
        for k=1:nMcIdx
            output=run3_data{i,j,k};
            try
            %output.impact_matrix=output.impact_matrix*-1;
            for l=1:maxNTarget
            nTarget=l;
            targets=output.attack_targets(nTarget,:)';
            owners=output.attack_owners(nTarget,:)';
            attack_value_matrix=output.impact_truth(targets==1,owners==1);
            attack_value=sum(sum(attack_value_matrix));
            attack_false_value_matrix=output.impact_matrix(targets==1,owners==1);
            attack_false_value=sum(sum(attack_false_value_matrix));
            attack_value_array(i,j,l,k)=attack_value;
            attack_false_value_array(i,j,l,k)=attack_false_value;
            end
            tmp=squeeze(target_atk_prob(i,j,:));
            tmp=tmp+output.attack_targets(4,:)';
            target_atk_prob(i,j,:)=tmp;
            max_target_impact(i,j,k)=max(max(output.impact_matrix));
            min_target_impact(i,j,k)=min(min(output.impact_matrix));
            total_gain_array(i,j,k)=sum(sum(output.impact_matrix(output.impact_matrix>0)));
            total_loss_array(i,j,k)=sum(sum(output.impact_matrix(output.impact_matrix<0)));
            %impact_stddev_array(i,j,k)=std(std(output.impact_matrix))./1;%mean(sum((output.impact_matrix),2));
            %q3=quantile(sum(output.impact_matrix,2),0.75);
            %q1=quantile(sum(output.impact_matrix,2),0.25);
            %impact_stddev_array(i,j,k)=(q3-q1)/(q3+q1);
            impact_stddev_array(i,j,k)=sum(std(output.impact_matrix,[],2));
            catch
                unsuccess(end+1)=output;
            end
        end
    end
end
return;

fid=fopen('tmp.txt','w');
for i=1:length(unsuccess)
    str=sprintf('qsub -l nodes=1,walltime=01:00:00 /scratch/cpssim/MATLAB/scripts/run3/%d.sh\n',unsuccess(i));
    fprintf(fid,'%s',str);
end
fclose all;

return;

nTarget=4;



max_target_prob=max(target_atk_prob,[],3)/nMcIdx;
std_target_prob=std(target_atk_prob,[],3)/nMcIdx;

figure;
hold all;
plot(nNoiseVals,std_target_prob);
xlabel('Std. Dev. of Noise');
ylabel('Std. of Target Attack Prob.');
hold off;


max_impact=nanmean(max_target_impact,3);
min_impact=nanmean(min_target_impact,3);

figure;
hold all;
plot(nOwnerVals,max_impact(1,:));
xlabel('Number of Owners');
ylabel('Max Impact at Any Actor');
hold off;

figure;
hold all;
plot(nOwnerVals,min_impact(1,:));
xlabel('Number of Owners');
ylabel('Min Impact at Any Actor');
hold off;




%Experiment 1
total_loss=mean(total_loss_array,3);
total_gain=mean(total_gain_array,3);
total_cv=mean(impact_stddev_array,3);
output=run3_data{1,1,1};
single_owner_loss=sum(sum(output.impact_truth,2));

figure;
hold all;
plot([1 nOwnerVals],-1*[single_owner_loss total_loss(1,:)],'--k','linewidth',3);
plot([1 nOwnerVals],[0 total_gain(1,:)],'-k','linewidth',3);
xh=xlabel('Number of Actors');
yh=ylabel('Amount of Gain/Loss in System');
lh=legend('Loss','Gain');
%grid on;
xlim([1 16]);
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
hold off;


%{
figure;
hold all;
boxplot(squeeze(total_gain_array(1,:,:))');
hold off;
%}


%Experiment 2

nTarget=5;
attack_values=nanmean(squeeze(attack_value_array(:,:,nTarget,:)),3);
%attack_values_err=std(attack_value_array,[],3);
attack_false_values=nanmean(squeeze(attack_false_value_array(:,:,nTarget,:)),3);

figure;
hold all;
plot(nNoiseVals,attack_values(:,1),'-k','linewidth',3);
plot(nNoiseVals,attack_values(:,2),'--k','linewidth',3);
plot(nNoiseVals,attack_values(:,3),'-.k','linewidth',3);
plot(nNoiseVals,attack_values(:,6),':k','linewidth',3);
%plot(nNoiseVals,attack_values(:,7),'--*k','linewidth',2);
xh=xlabel('\sigma of Noise');
yh=ylabel('Profit of Attack');
lh=legend('2-Actors','4-Actors','6-Actors','12-Actors');%,'16-Actors');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
hold off;

figure
hold all
plot(1:maxNTarget,nanmean(squeeze(attack_value_array(1,1,:,:)),2),'-k','linewidth',3);
plot(1:maxNTarget,nanmean(squeeze(attack_value_array(1,2,:,:)),2),'--k','linewidth',3);
plot(1:maxNTarget,nanmean(squeeze(attack_value_array(1,3,:,:)),2),'-.k','linewidth',3);
plot(1:maxNTarget,nanmean(squeeze(attack_value_array(1,6,:,:)),2),':k','linewidth',3);
xh=xlabel('Number of Targets Attacked');
yh=ylabel('Profit of Attack');
lh=legend('2-Actors','4-Actors','6-Actors','12-Actors');%,'16-Actors');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
xlim([2 maxNTarget]);
hold off;


figure;
hold all;
plot(nNoiseVals,attack_values(:,3),'-k','linewidth',3);
plot(nNoiseVals,attack_false_values(:,3),'--k','linewidth',3);
%plot(nNoiseVals,attack_values(:,7),'--*k','linewidth',2);
xh=xlabel('\sigma of Noise');
yh=ylabel('Profit of Attack');
lh=legend('Observed','Anticipated');%,'16-Actors');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
hold off;

