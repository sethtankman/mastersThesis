function outp = confidence_max_sat(R,inp,outp_inx)
% Son N. Tran
% R.r: vNum x number_of_rules --> (-1,0,1) matrix
% R.c: 1xnumber_of_rules      --> real positive values
sNum = size(inp,2);
threshold = sum(abs(R.r));
all_c = [];
for l=[0,1]
    inp(outp_inx,:) = l;
    sat = ((2*inp'-1)*R.r == repmat(threshold,[sNum,1]));
    sat = bsxfun(@times,sat,R.c);
    all_c = [all_c,sum(sat,2)];
end
[~,outp] = max(all_c,[],2);
outp=outp-1;
end