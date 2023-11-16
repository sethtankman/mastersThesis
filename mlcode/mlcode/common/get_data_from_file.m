function data = get_data_from_file(dat_file,row_dat)
    vars = whos('-file', dat_file);
    A = load(dat_file,vars(1).name);
    data = A.(vars(1).name);
    if nargin==2 && row_dat, data = data'; end
    if size(data,2)==1 && size(data,1)>1, data = data'; end
end

