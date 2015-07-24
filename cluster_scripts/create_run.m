function [ ] = create_run(run_id,function_name,varargin)

%Example:
%startup; create_run(1,'run_impact_matrix_calc',[0.05 0.1 0.15 0.2 0.25],[2 3 4 8 16],[1:10]);

base_param_num=2;

qsub_args='qsub -l nodes=1,walltime=00:10:00';
exec_dir='/scratch/cpssim/MATLAB';
%exec_dir='D:/temp';
data_dir=strcat(exec_dir,'/rundata');
script_dir=strcat(exec_dir,'/scripts');
mkdir(data_dir);
mkdir(script_dir);


lenparam=[];
for i=base_param_num+1:nargin
	param=varargin{i-base_param_num};
	lenparam(end+1)=length(param);
end

%numparam=lenparam(1);
%for i=2:length(lenparam)
%	numparam=numparam*lenparam(i);
%end

x=1:max(max(lenparam));
n=length(lenparam);
m = length(x);
X = cell(1, n);
[X{:}] = ndgrid(x);
X = X(end : -1 : 1); 
y = cat(n+1, X{:});
y = reshape(y, [m^n, n]);

for i=1:length(lenparam)
	testval=lenparam(i);
	testvect=y(:,i);
	y(testvect>testval,:)=[];
end

num_job_id=length(y);

submit_script=strcat(script_dir,'/run_',num2str(run_id),'.sh');
fid=fopen(submit_script,'w');

load_script=strcat(script_dir,'/load_run_',num2str(run_id),'.m');
lfid=fopen(load_script,'w');
sizestr=sprintf('%.0f,',max(y));
sizestr(end)='';
dataname=sprintf('run%d_data',run_id);
fprintf(lfid,'%s=cell(%s);\n',dataname,sizestr);

base_store_file=strcat(script_dir,'/run',num2str(run_id),'/');
mkdir(base_store_file);

for i=1:num_job_id
	idx=y(i,:);
	param_string=[];
	for k=1:length(idx)
		tmp=varargin{k};
		param_string=strcat(param_string,num2str(tmp(idx(k))),',');
    end
	param_string(end)='';
	exec_str=strcat(function_name,'(',param_string,')');
	store_file=strcat(base_store_file,num2str(i),'.sh');
	job_data_dir=strcat(data_dir,'/run',num2str(run_id),'/job',num2str(i));
	create_script(store_file,exec_str,exec_dir,job_data_dir,run_id,i);
	fprintf(fid,'%s %s\n',qsub_args,store_file);
	idxstr=sprintf('%.0f,',idx);
	idxstr(end)='';
	loaddata_file=strcat(job_data_dir,'/run',num2str(run_id),'_job',num2str(i),'.mat');
	fprintf(lfid,'try\n');
    fprintf(lfid,'x=load(''%s'');\n',loaddata_file);
	fprintf(lfid,'%s{%s}=x.output;\n',dataname,idxstr);
	fprintf(lfid,'catch e\nx=%d;\n ',i);
	fprintf(lfid,'%s{%s}=x;\nend\n\n',dataname,idxstr);
end

for i=base_param_num+1:nargin
	k=i-base_param_num;
	param=varargin{k};
	fprintf(lfid,'run%d_input.v%d=%s;\n',run_id,k,mat2str(param));
end

finalfile=strcat(data_dir,'/run',num2str(run_id),'.mat');
%Octave:
fprintf(lfid,'save(''-v7'',''%s'',''%s'',''run%d_input'');\n',finalfile,dataname,run_id);
%MATLAB:
%fprintf(lfid,'save(''%s'',''%s'',''run%d_input'');\n',finalfile,dataname,run_id);

fclose(fid);
fclose(lfid);


end
