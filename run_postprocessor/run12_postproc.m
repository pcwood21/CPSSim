%load('run12.mat'); %loads run11_data and run11_input

nOwner_vals=run12_input.v1;
nOwner_len=length(nOwner_vals);
mc_num_vals=run12_input.v2;
mc_num_len=length(mc_num_vals);
dec_vals = run12_input.v3;

nAssets=11;
unsuccess=[];
unsucces_index = 1;
nTargets=5;

mean_atk_value=1295.5;

sum_impact_array=zeros(nOwner_len,mc_num_len,nAssets);
deceptive_impact=zeros(nOwner_len,mc_num_len,nAssets);

for i=1:nOwner_len
    for j=1:mc_num_len
        for k = 1:nAssets
            output=run12_data{i,j,k};
            try
                %Process data here
                %output.sum_impact=sum_impact;
                %output.deceptive_impact=deceptive_impact;
                %output.attack_values_array=attack_values_array;
                %output.attack_false_values_array=attack_false_values_array;
                %output.atk_true_value=atk_true_value;
                %output.impact_truth=truth_impact;
                %output.ownership=rand_own;
                %output.linprog_params=linprog_params;
                %output.nOwners=nOwners;
                %output.mc_num=mc_num;

                %Example:
                %sum_impact_array(i,j,:)=output.sum_impact;

                deceptive_impact(i,j,k) = output.deceptive_impact;

            catch
                unsuccess(unsucces_index)=output;
                unsucces_index = unsucces_index + 1;
            end
        end
    end
end

return;

%Example plot data

%sum_impact = squeeze(mean(sum_impact_array,2));
deceptive_impact = squeeze(mean(deceptive_impact,2));


x=1:11;
%plot(x,sum_impact(nown_idx,x));

plot(dec_vals,deceptive_impact(1,x));

%for i = 1:nOwner_len
    for i=3
    figure;

    hold all;
    plot(100*(dec_vals),deceptive_impact(i,x)/mean_atk_value*100,'-k','linewidth',2);
    xh=xlabel('Percentage Change in Max Capacity');
    yh=ylabel('% Reduction of Attacker''s Incentive');
    %th = title(['Number of Owners = ' num2str(nOwner_vals(i))]);
    set(gca,'FontSize',14,'FontWeight','bold');
    set(xh,'FontSize',14,'FontWeight','bold');
    set(yh,'FontSize',14,'FontWeight','bold');
    %set(th,'FontSize',14,'FontWeight','bold');
    ylim([0 30]);
    hold off;
end

% %%Old Experiment Example Plots
% 
% risk_mitigated=-1*median(risk_mitigated_array(:,:,:,:),4);
% protection_cost=median(protection_cost_array(:,:,:,:),4);
% defense_roi=risk_mitigated./protection_cost;
% risk_mitigated_c=-1*median(risk_mitigated_array_c(:,:,:,:),4);
% protection_cost_c=median(protection_cost_array_c(:,:,:,:),4);
% defense_roi_c=risk_mitigated_c./protection_cost_c;
% 
% 
% %Experiment 3a
% figure
% hold all;
% plot_param=risk_mitigated;
% %plot_param=defense_roi;
% plot(noise_defender_vals,squeeze(plot_param(1,:,1)),'-k','linewidth',2);
% plot(noise_defender_vals,squeeze(plot_param(1,:,2)),'--k','linewidth',2);
% plot(noise_defender_vals,squeeze(plot_param(1,:,3)),'-.k','linewidth',2);
% plot(noise_defender_vals,squeeze(plot_param(1,:,4)),':k','linewidth',2);
% %plot(noise_defender_vals,squeeze(mean(risk_mitigated(1,:,:),3)),'-b','linewidth',3);
% %plot(noise_defender_vals,squeeze(mean(risk_mitigated_c(1,:,:),3)),'--b','linewidth',3);
% xh=xlabel('\sigma Noise for Defender');
% yh=ylabel('Reduction in Impact of Attack');
% lh=legend('2-Actors','4-Actors','6-Actors','12-Actors');%,'16-Actors');
% set(gca,'FontSize',14,'FontWeight','bold');
% set(xh,'FontSize',14,'FontWeight','bold');
% set(yh,'FontSize',14,'FontWeight','bold');
% set(lh,'FontSize',14,'FontWeight','bold');
% %xlim([1 maxNTarget]);
% hold off;
% 
% %Experiment 3b
% figure
% hold all;
% plot(noise_defender_vals,squeeze(risk_mitigated(1,:,3)),'-k','linewidth',2);
% plot(noise_defender_vals,squeeze(risk_mitigated_c(1,:,3)),'--k','linewidth',2);
% xh=xlabel('\sigma Noise for Defender');
% yh=ylabel('Reduction in Impact of Attack');
% lh=legend('W/O Collab.','W/ Collab.');%,'16-Actors');
% set(gca,'FontSize',14,'FontWeight','bold');
% set(xh,'FontSize',14,'FontWeight','bold');
% set(yh,'FontSize',14,'FontWeight','bold');
% set(lh,'FontSize',14,'FontWeight','bold');
% %xlim([1 maxNTarget]);
% hold off;