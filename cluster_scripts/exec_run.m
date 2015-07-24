function exec_run(save_file,exec_str)

[output]=eval(exec_str);

save(save_file,'output');

end