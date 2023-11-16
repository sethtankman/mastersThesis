clear all;
addpath(genpath('/home/tra161/WORK/projects/DeepSymbolic/code'));
EXP_DIR = '/home/tra161/WORK/experiments/DS/extraction/HEART/RBM/';

% Load data
load('/home/tra161/WORK/Data/UCI/HEART/heart_trn_dat.mat')
load('/home/tra161/WORK/Data/UCI/HEART/heart_trn_lab.mat')
load('/home/tra161/WORK/Data/UCI/HEART/heart_tst_dat.mat')
load('/home/tra161/WORK/Data/UCI/HEART/heart_tst_lab.mat')

%size(trn_dat)
%size(trn_lab)

data = [trn_dat';trn_lab'];

model_f =  strcat(EXP_DIR,'model.mat');
if ~exist(model_f,'file')
conf.hNum   = 1;
conf.sNum   = 0;
conf.bNum   = 0;
conf.eNum   = 500;
conf.gNum   = 1;
conf.params =  [0.1,0.1,0,0];
conf.use_vis_bias = 0;
conf.prediction = 0;
conf.lr_decay_num = 5;
conf.early_stop_num = 5;

conf.infer_type = 'stochastic';

model = binary_rbm(conf,data);
save(model_f,'model');
else
load(model_f);
end


pred_dat = data(1:end-1,:);
pred_lab = data(end,:);
pred_inx = size(data,1);

[g,c] = pre_acc(model.W,model.visB,model.hidB,pred_dat,pred_lab)

%R = rbm_energy_rank_ext(model,[]);
R = rbm_energy_search_ext(model,[],data);

o = confidence_max_sat(R,[pred_dat;0.5*ones(1,size(pred_dat,2))],pred_inx);
[pred_lab',o]
mean(pred_lab'==o)


