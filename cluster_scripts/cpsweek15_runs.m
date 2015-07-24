startup; create_run(2,'run_impact_matrix_calc',[0:0.05:0.5],[2:2:16],[1:50]);

startup; create_run(3,'run3_impact_matrix_calc',[0:0.05:0.5],[2:2:16],[1:100]);

startup; create_run(4,'run4_defender_analysis',[0:0.1:0.5],[0:0.1:0.5],[2 4 6 12],[1:10]);

startup; create_run(5,'run5_defender_analysis',[0 0.05 0.1],[0],[2 4 6 12],[1:50]); %For Bar Plot exp 3

create_run(6,'run5_defender_analysis',[0.1],[0:0.05:0.25],[2 4 6 12],[1:100]); %For exp 3 actor vs noise

create_run(7,'run6_defender_analysis',[0 0.05 0.1],[0],[2 4 6 12],[1:100]);

create_run(8,'run8_ind_profit',[0:0.025:0.5],[2 4 6 12],[100]);

create_run(9,'run9_ind_impact',[0:0.025:0.5],[2 4 6 12],[1:1:100]);