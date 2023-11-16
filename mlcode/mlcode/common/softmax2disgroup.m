function odat = softmax2disgroup(idat,d_ranges)

SZ = size(idat,2);
Num = numel(d_ranges);
d_ranges = repmat(d_ranges,1,SZ);

d_ranges = find(idat) - cumsum([0,d_ranges(1:end-1)])';
odat = reshape(d_ranges,[Num,SZ]);
end