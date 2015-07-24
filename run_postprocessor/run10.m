
%Input Params

[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();
output=run9_data{1,1,1};
impact_matrix=output.truth_impact;
doc=calc_degree_of_competition(impact_matrix,edges,capacity);
potential_edges=[1 2;1 3;1 5;1 6;1 7;1 8;1 12;1 13;1 19;1 20;1 24;2 1;2 3;2 4;2 5;2 6;2 7;2 8;2 9;2 11;2 12;2 14;2 19;2 20;2 21;2 23;2 24;3 1;3 2;3 4;3 5;3 6;3 8;3 9;3 10;3 11;3 15;3 20;3 21;3 22;3 23;4 2;4 3;4 5;4 6;4 9;4 10;4 11;4 16;4 21;4 22;4 23;5 1;5 2;5 3;5 4;5 6;5 8;5 9;5 10;5 11;5 12;5 17;5 20;5 21;5 22;5 23;5 24;6 1;6 2;6 3;6 4;6 5;6 7;6 8;6 11;6 12;6 18;6 19;6 20;6 23;6 24;7 13;7 14;7 18;7 25;8 13;8 14;8 15;8 17;8 18;8 26;9 14;9 15;9 16;9 17;9 27;10 15;10 16;10 17;10 28;11 14;11 15;11 16;11 17;11 18;11 29;12 13;12 14;12 17;12 18;12 30;13 14;13 15;13 17;13 18;13 25;13 26;13 30;14 13;14 15;14 16;14 17;14 18;14 25;14 26;14 27;14 29;14 30;15 13;15 14;15 16;15 17;15 18;15 26;15 27;15 28;15 29;16 14;16 15;16 17;16 18;16 27;16 28;16 29;17 13;17 14;17 15;17 16;17 18;17 26;17 27;17 28;17 29;17 30;18 13;18 14;18 15;18 16;18 17;18 25;18 26;18 29;18 30;31 1;31 2;31 6;31 7;31 19;32 1;32 2;32 3;32 5;32 6;32 8;32 20;33 2;33 3;33 4;33 5;33 9;33 21;34 3;34 4;34 5;34 10;34 22;35 2;35 3;35 4;35 5;35 6;35 11;35 23;36 1;36 2;36 5;36 6;36 12;36 24;40 15;40 16;40 17;40 28;41 14;41 15;41 16;41 17;41 18;41 29;42 13;42 14;42 17;42 18;42 30;43 13;43 14;43 18;43 25;45 14;45 15;45 16;45 17;45 27;46 15;46 16;46 17;46 28;49 13;49 14;49 18;49 25;50 13;50 14;50 15;50 17;50 18;50 26;51 14;51 15;51 16;51 17;51 27;52 15;52 16;52 17;52 28;53 14;53 15;53 16;53 17;53 18;53 29;54 13;54 14;54 17;54 18;54 30;55 13;55 14;55 18;55 25;56 13;56 14;56 15;56 17;56 18;56 26;57 14;57 15;57 16;57 17;57 27;58 15;58 16;58 17;58 28;59 14;59 15;59 16;59 17;59 18;59 29;60 13;60 14;60 17;60 18;60 30;61 13;61 14;61 18;61 25;62 13;62 14;62 15;62 17;62 18;62 26;63 14;63 15;63 16;63 17;63 27;64 15;64 16;64 17;64 28;65 14;65 15;65 16;65 17;65 18;65 29;66 13;66 14;66 17;66 18;66 30;67 13;67 14;67 18;67 25;68 13;68 14;68 15;68 17;68 18;68 26;69 14;69 15;69 16;69 17;69 27;70 15;70 16;70 17;70 28;71 14;71 15;71 16;71 17;71 18;71 29;72 13;72 14;72 17;72 18;72 30];

doc_diff=zeros(size(potential_edges,1),1);
for i=1:size(potential_edges,1)
    x=potential_edges(i,1);
    y=potential_edges(i,2);
    doc_diff(i)=doc(y);
end

output=run10_data{1,1,1};
nEdgeIdx=size(run10_data,1);
nEdgeIdxVals=run10_input.v1;
nOwnerIdx=size(run10_data,2);
nOwnerVals=run10_input.v2;
mc_num_vals=run10_input.v3;
mc_num=length(mc_num_vals);

unsuccessful=[];


attack_value=zeros(nEdgeIdx,nOwnerIdx,mc_num)*NaN;

maxnTargets=8;

mean_atk_value=1295.5;

nTargets=5;

unsuccess=[];
for i=1:nEdgeIdx
    for j=1:nOwnerIdx
        for k=1:mc_num
            output=run10_data{i,j,k};
            try
            
            
            attack_value(i,j,k)=output.attack_value(nTargets);
            
            catch
                unsuccess(end+1)=output;
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

atkval=mean(attack_value,3);
nownidx=3;

newEdgeAtkVal=atkval(:,3);

[seav,nidx]=sort(newEdgeAtkVal,1,'ascend');
tdoc=doc_diff(nidx);

seav=(mean_atk_value-seav)/mean_atk_value;

ssum=zeros(20,1);
for i=1:20
    ssum(i)=sum(seav(1:i));
end



%Experiment 2 -- Edge Insertion

figure;
hold all;
i=nownidx;
nv=seav(1:15)*100;
bar(nv,'k');
xlim([0 16]);
ylim([20 35]);
%lh=legend('Gains','Losses','Inefficiency','Location','NorthWest');
xh=xlabel('Top Potential Edges');
yh=ylabel('% Reduction in Attacker''s Incentive');
set(gca,'FontSize',14,'FontWeight','bold');
set(xh,'FontSize',14,'FontWeight','bold');
set(yh,'FontSize',14,'FontWeight','bold');
%set(lh,'FontSize',14,'FontWeight','bold');
hold off;

%Experiment 2 -- Benefit of Information Sharing

