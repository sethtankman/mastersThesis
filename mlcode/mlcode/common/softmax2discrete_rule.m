function rules =  softmax2discrete_rule(r,d_ranges)
rules = [];
start_inx = 1;
for i=1:size(d_ranges,1)
    end_inx = start_inx + d_ranges(i) -1;
    d = max(bsxfun(@times,r(start_inx:end_inx,:),[1:d_ranges(i)]'));
   
    rules = [rules;d];
    start_inx = end_inx+1;
end
end