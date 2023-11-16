function vis2hid_file(model,dat_file,new_file,row_dat)
if nargin <4, row_dat = 0; end
    dat = logistic(bsxfun(@plus,model.W'*get_data_from_file(dat_file,row_dat),model.hidB));
    save(new_file,'dat');
end

