RS_DIR = '/home/tra161/WORK/experiments/DS/eblm/Kinship/encode_ae/'
RS_DIR = '/home/tra161/Downloads/eblm/Kinship_split/encode_ae_noshare/'
fs = dir(strcat(RS_DIR,'*.mat'));
accs = [];
fnames = {};
for i = 1:numel(fs)
    load(strcat(RS_DIR,fs(i).name));
    accs = [accs, mean(rs)];
    fnames = [fnames,fs(i).name];
end

[~,rank] = sort(accs,'descend');
for r = rank
    fprintf('%.5f %s\n',accs(r),fnames{r});
end