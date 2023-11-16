clear all;
RS_DIR = ['/home/tra161/WORK/experiments/DS/eblm/Kinship_split_exp3/' ...
          'encode_ae/']
%RS_DIR = '/home/tra161/eblm/Kinship_split_exp3/encode_ae_noshare/';
N = 20;
fs = dir(strcat(RS_DIR,'*N',num2str(N),'*trial1.mat'));
accs = [];
m_ = N;
ms = [];
fnames = {};
for i = 1:numel(fs)
    alltrials = dir(strrep(strcat(RS_DIR,fs(i).name),'trial1','trial*'));
    rss = [];
    fnames = [fnames,strrep(fs(i).name,'_trial1.mat','')];
    for j =1:numel(alltrials)
        load(strcat(RS_DIR,alltrials(j).name));        
        rss = [rss,sum(1-rs)];
    end
    if m_>mean(rss), m_ = mean(rss); mf_ = fs(i).name; end
    ms = [ms;mean(rss)];

    if mean(rss)<=0.7
    rss
    fs(i).name
    end
    %accs = [accs; rss];    
end


[~,rank] = sort(ms,'descend');
for r = rank'
    fprintf('%.5f %s\n',ms(r) ,fnames{r});
end