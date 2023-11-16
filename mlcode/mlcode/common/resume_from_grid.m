function inx = resume_from_grid(log_file,inx_size);
% The function read the log file and resume the grid search for params
% sontran 2013
stt  = exist(log_file,'file');
if stt == 0
    inx = ones(1,inx_size);
else    
    load(log_file);
    inx = data(end,:);
    inx = inx(1:inx_size);
end
end

