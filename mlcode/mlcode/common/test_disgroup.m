load ~/My.Academic/DATA/OTHERS/UCI_Car/car_trn_dat.mat

d_ranges = [];
for i=1:size(trn_dat,1)
    d_ranges = [d_ranges;numel(unique(trn_dat(i,:)))];
end
    sum(sum(trn_dat - softmax2disgroup(disgroup2softmax(trn_dat,d_ranges),d_ranges)))
