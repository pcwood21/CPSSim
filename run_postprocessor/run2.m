
%Note: For Run 2, impact was inverted, and results nullified for attacker
%strategy

output=run2_data{1,1,1};
nEdges=size(output.impact_matrix,1);
nNoiseIdx=size(run2_data,1);
nNoiseVals=run2_input.v1;
nOwnerIdx=size(run2_data,2);
nOwnerVals=run2_input.v2;
nMcIdx=size(run2_data,3);
attack_value_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx);
attack_false_value_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx);
target_atk_prob=zeros(nNoiseIdx,nOwnerIdx,nEdges);
max_target_impact=zeros(nNoiseIdx,nOwnerIdx,nMcIdx);
min_target_impact=zeros(nNoiseIdx,nOwnerIdx,nMcIdx);
total_gain_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx);
total_loss_array=zeros(nNoiseIdx,nOwnerIdx,nMcIdx);
for i=1:nNoiseIdx
    for j=1:nOwnerIdx
        for k=1:nMcIdx
            output=run2_data{i,j,k};
            output.impact_matrix=output.impact_matrix*-1;
            attack_value_array(i,j,k)=output.attack_value;
            attack_false_value_array(i,j,k)=output.attack_false_value;
            tmp=squeeze(target_atk_prob(i,j,:));
            tmp=tmp+output.attack_targets;
            target_atk_prob(i,j,:)=tmp;
            max_target_impact(i,j,k)=max(max(output.impact_matrix));
            min_target_impact(i,j,k)=min(min(output.impact_matrix));
            total_gain_array(i,j,k)=sum(sum(output.impact_matrix(output.impact_matrix>0)));
            total_loss_array(i,j,k)=sum(sum(output.impact_matrix(output.impact_matrix<0)));
        end
    end
end

return;

attack_values=mean(attack_value_array,3);
attack_values_err=std(attack_value_array,[],3);
attack_false_values=mean(attack_false_value_array,3);

figure;
hold all;
plot(nNoiseVals,attack_values);
%errorbar(nNoiseVals,attack_values(:,1),attack_values_err(:,1));
plot(nNoiseVals,attack_false_values);
plot(nNoiseVals,mean(attack_values,2),'--','linewidth',3);
plot(nNoiseVals,mean(attack_false_values,2),'-','linewidth',3);
grid on;
xlabel('Std. Dev. of Noise');
ylabel('Profit of Attack (Anticipated vs Actual)');
hold off;

max_target_prob=max(target_atk_prob,[],3)/nMcIdx;
std_target_prob=std(target_atk_prob,[],3)/nMcIdx;

figure;
hold all;
plot(nNoiseVals,std_target_prob);
xlabel('Std. Dev. of Noise');
ylabel('Std. of Target Attack Prob.');
hold off;


max_impact=mean(max_target_impact,3);
min_impact=mean(min_target_impact,3);

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


total_loss=mean(total_loss_array,3);
total_gain=mean(total_gain_array,3);
output=run2_data{1,1,1};
single_owner_loss=sum(sum(-1*output.impact_truth,2));


%{
figure;
hold all;
plot([1 nOwnerVals],[0 total_gain(1,:)]);
xlabel('Number of Owners');
ylabel('Total Gain in System');
grid on;
hold off;
%}

figure;
hold all;
plot([1 nOwnerVals],-1*[single_owner_loss total_loss(1,:)],'-.','linewidth',2);
plot([1 nOwnerVals],[0 total_gain(1,:)],'--','linewidth',2);
xlabel('Number of Owners');
ylabel('Total Gain/Loss in System');
legend('Loss','Gain');
grid on;
hold off;

