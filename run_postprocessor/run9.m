
%Note: For Run 2, impact was inverted, and results nullified for attacker
%strategy

output=run9_data{1,1};
nNoiseIdx=size(run9_data,1);
nNoiseVals=run9_input.v1;
nOwnerIdx=size(run9_data,2);
nOwnerVals=run9_input.v2;
mc_num_vals=run9_input.v3;
mc_num=length(mc_num_vals);

unsuccessful=[];

%Repair attack assessment
%{
parfor i=1:nNoiseIdx
    for j=1:nOwnerIdx
        for k=1:mc_num
            output=run9_data{i,j,k};
            if isstruct(output)
                
                timp_truth=output.
            for l=1:nOwnerVals(j)
                timp_random=output.owner_impact{l};
                if max(output.attack_values_array_cell{l}) == 0
                nOwners=nOwnerVals(j);
                    nEdges=size(timp_random,1);
                    
                	nTargetMax=5;

                    attack_values_array=zeros(nTargetMax,1);
                    attack_false_values_array=zeros(nTargetMax,1);
                    attack_targets_array=zeros(nTargetMax,nEdges);
                    attack_owners_array=zeros(nTargetMax,nOwners);
                    local_impact=zeros(nTargetMax,1);
                    
                    try
                    for m=5:nTargetMax
                        [atk_owners,atk_targets,atk_false_value]=attacker_strategy(timp_random,m);
                        atk_values=timp_random(:,atk_owners);
                        attack_values_array(m)=sum(sum(atk_values(atk_targets,1:size(atk_values,2))));
                        atk_local_values=timp_random(:,atk_owners);
                        attack_values_array(m)=sum(sum(atk_local_values(atk_targets,1:size(atk_local_values,2))));
                        attack_false_values_array(m)=atk_false_value;
                        row=zeros(1,nEdges);
                        row(atk_targets)=1;
                        attack_targets_array(m,:)=row;
                        row=zeros(1,nOwners);
                        row(atk_owners)=1;
                        attack_owners_array(m,:)=row;
                        local_impact(m)=sum(timp_random(attack_targets_array(m,:)==1,l));
                    end
                    catch
                    end
                    output.attack_values_array_cell{l}=attack_values_array;
                    output.attack_false_values_array_cell{l}=attack_false_values_array;
                    output.attack_targets_array_cell{l}=attack_targets_array;
                    output.attack_owners_array_cell{l}=attack_owners_array;
                    output.local_impact_cell{l}=local_impact;
                end
                    
            end
            run9_data{i,j,k}=output;
            else
               % unsuccessful(end+1)=output;
            end
        end
    end
end
return;
%}
%End Repair

mismatch_values=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;
fneg_values=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;
fpos_values=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;
mismatch_valuesn=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;
max_roi=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;
min_roi=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;
gain_potential=zeros(nOwnerIdx,mc_num)*NaN;
loss_potential=zeros(nOwnerIdx,mc_num)*NaN;

atk_values=zeros(nNoiseIdx,nOwnerIdx,mc_num)*NaN;

maxnTargets=5;

nTargets=5;

unsuccess=[];
parfor i=1:nNoiseIdx
    for j=1:nOwnerIdx
        for k=1:mc_num
            output=run9_data{i,j,k};
            try

            ti=output.truth_impact;
            
            [~,atk_targets,atk_value]=attacker_strategy(ti,nTargets);
            row=zeros(1,size(ti,1));
            row(atk_targets)=1;
            atk_targets=row;
            
                atk_values(i,j,k)=atk_value;
            
            fneg_val=zeros(size(ti,2),1);
            fpos_val=zeros(size(ti,2),1);
            for l=1:size(ti,2)
                expected_targets=output.attack_targets_array_cell{l};
                expected_targets=expected_targets(nTargets,:);
                fneg_val(l)=sum(ti(xor(atk_targets==1,expected_targets==1) & atk_targets==1,l));
                fpos_val(l)=sum(ti(xor(atk_targets==1,expected_targets==1) & expected_targets==1,l));
            end
            
            
            fneg_values(i,j,k)=sum(abs(fneg_val));
            fpos_values(i,j,k)=sum(abs(fpos_val));
            
            mismatch_values(i,j,k)=sum(abs(output.mismatch_value(:,nTargets)));
            
            
            
            %Negative impact diff implies overinvestment
            %Positive impact diff implies underinvestment
            delta_profits=output.orig_profits-output.ind_profits;
            mismatch_amounts=abs(output.mismatch_value(:,nTargets));
            roi=delta_profits./mismatch_amounts;
            max_roi(i,j,k)=median(roi(roi>0));
            min_roi(i,j,k)=median(roi(roi<0));
            
            catch
                %unsuccess(end+1)=output;
            end
        end
    end
end

fid=fopen('tmp.txt','w');
for i=1:length(unsuccess)
    str=sprintf('qsub -l nodes=1,walltime=01:00:00 /scratch/cpssim/MATLAB/scripts/run3/%d.sh\n',unsuccess(i));
    fprintf(fid,'%s',str);
end
fclose all;

return;


figure;
hold all;
nv=squeeze(nanmean(mismatch_values(:,4,:),3));
plot(nNoiseVals,nv)
nv=squeeze(nanmean(max_roi(:,2,:),3));
plot(nNoiseVals,nv)
nv=squeeze(nanmean(min_roi(:,2,:),3));
plot(nNoiseVals,nv)
hold off;



figure;
hold all;
plot(nNoiseVals,ind_system_profits(:,3));
plot(nNoiseVals,orig_system_profits(:,3));
legend('Local View','Global View');
xlabel('Std. Dev. of Noise');
ylabel('System Profitability');
hold off;

figure;
hold all;
for i=1:length(nOwnerVals)
plot(nNoiseVals,ind_system_profits(:,i));
end
legend('2','4','6','12');
xlabel('Std. Dev. of Noise');
ylabel('System Profitability');
hold off;

figure;
hold all;
for i=1:length(nOwnerVals)
plot(nNoiseVals,loss_system_profits(:,i));
end
legend('2','4','6','12');
hold off;


%Experiment 1 -- Benefit of Info Sharing

figure;
hold all;
i=3;
nv=squeeze(nanmean(mismatch_values(:,i,:),3));
plot(nNoiseVals,nv,'-k','linewidth',2);
%lh=legend('Gains','Losses','Inefficiency','Location','NorthWest');
xh=xlabel('\sigma Noise for Independent Actors');
yh=ylabel('Impact Inaccuracy');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
%set(lh,'FontSize',14,'FontWeight','bold');
hold off;

%exp 1a
figure;
hold all;
i=3;
nv=squeeze(nanmean(fneg_values(:,i,:),3));
plot(nNoiseVals,nv,'-','linewidth',2);
%nv=squeeze(nanmean(fpos_values(:,i,:),3));
%plot(nNoiseVals,nv,'--','linewidth',2);
%lh=legend('Gains','Losses','Inefficiency','Location','NorthWest');
xh=xlabel('\sigma Noise for Independent Actors');
yh=ylabel('Impact of Under-Investment');
%lh=legend('False Negative','False Positive');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
%set(lh,'FontSize',14,'FontWeight','bold');
hold off;

%Experiment 2 -- Benefit of Information Sharing

