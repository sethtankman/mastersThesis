function odat = disgroup2softmax(idat,d_ranges)
% Convert group of discrete variables to sofmaxes
% Son Tran
SZ =size(idat,2);
odat = zeros(sum(sum(d_ranges)),SZ);
d_ranges = repmat(d_ranges,1,SZ);
d_ranges = d_ranges(1:end-1);
d_ranges = cumsum([0,d_ranges(:)']) + idat(:)';

odat(d_ranges) = 1;
end