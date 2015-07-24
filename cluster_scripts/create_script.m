function [ ] = create_script(store_file,exec_str,exec_dir,data_dir,run_id,job_id)

fid=fopen(store_file,'w');

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#PBS -o ''%s/qsub.out''\n',data_dir);
fprintf(fid,'#PBS -e ''%s/qsub.err''\n',data_dir);
fprintf(fid,'cd %s\n',exec_dir);
fprintf(fid,'mkdir -p %s\n',data_dir);
save_file=strcat(data_dir,'/run',num2str(run_id),'_job',num2str(job_id),'.mat');
output_temp=sprintf('/local/console_run%d_job%d.out',run_id,job_id);
fprintf(fid,'octave --eval "startup; exec_run(''%s'',''%s'');" >> %s\n',save_file,exec_str,output_temp);
fprintf(fid,'gzip %s\n mv %s.gz %s\n',output_temp,output_temp,data_dir);

fclose(fid);


end