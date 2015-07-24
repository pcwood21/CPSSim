
%Note: For Run 2, impact was inverted, and results nullified for attacker
%strategy

output=run8_data{1,1};
nNoiseIdx=size(run8_data,1);
nNoiseVals=run8_input.v1;
nOwnerIdx=size(run8_data,2);
nOwnerVals=run8_input.v2;

ind_system_profits=zeros(nNoiseIdx,nOwnerIdx)*NaN;
max_ind_system_profit=zeros(nNoiseIdx,nOwnerIdx)*NaN;
min_ind_system_profit=zeros(nNoiseIdx,nOwnerIdx)*NaN;
var_system_profits=zeros(nNoiseIdx,nOwnerIdx)*NaN;
orig_system_profits=zeros(nNoiseIdx,nOwnerIdx)*NaN;
gain_system_profits=zeros(nNoiseIdx,nOwnerIdx)*NaN;
loss_system_profits=zeros(nNoiseIdx,nOwnerIdx)*NaN;

unsuccess=[];
for i=1:nNoiseIdx
    for j=1:nOwnerIdx
            output=run8_data{i,j};
            try
            
            op=output.orig_profits;
            mop=mean(sum(op,2));
            orig_system_profits(i,j)=mop;
            
            
            ip=output.ind_profits;
            mip=mean(sum(ip,2));
            ind_system_profits(i,j)=mip;
            
            gain_diff=op-ip;
            pos_diff=gain_diff;
            pos_diff(pos_diff<0)=0;
            neg_diff=gain_diff;
            neg_diff(neg_diff>0)=0;
            gain_system_profits(i,j)=mean(sum(pos_diff,2));
            loss_system_profits(i,j)=mean(sum(neg_diff,2));
            
            max_ind_system_profit(i,j)=mean(max(ip,[],2));
            min_ind_system_profit(i,j)=mean(min(ip,[],2));
            
            vip=std(ip,[],2);
            var_system_profits(i,j)=mean(vip);
            
            
            
            
            
            catch
                unsuccess(end+1)=output;
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


%Experiment 1 -- Cost of Information Sharing

figure;
hold all;
i=3;
plot(nNoiseVals,gain_system_profits(:,i),'-','linewidth',2);
plot(nNoiseVals,loss_system_profits(:,i),'--','linewidth',2);
plot(nNoiseVals,orig_system_profits(:,i)-ind_system_profits(:,i),'-.','linewidth',2);
%plot(nNoiseVals,gain_system_profits(:,i)+loss_system_profits(:,i));
lh=legend('Gains','Losses','Inefficiency','Location','NorthWest');
xh=xlabel('\sigma Noise for Independent Actors');
yh=ylabel('Income Change');
ylim([-250 250]);
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
set(lh,'FontSize',14,'FontWeight','bold');
hold off;

%Experiment 2 -- Benefit of Information Sharing

