function fts = get_features_discrete_dat(model,dat)
dat_ranges = [];

for i=1:size(dat,1)
    dat_ranges = [dat_ranges;numel(unique(dat(i,:)))];
end

dat = disgroup2softmax(dat,dat_ranges);
fts = logistic(bsxfun(@plus,model.W'*dat,model.hidB));
end