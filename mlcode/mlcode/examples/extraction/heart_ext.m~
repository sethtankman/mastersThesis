clear all;
addpath(genpath('/home/tra161/WORK/projects/DeepSymbolic/code'));
EXP_DIR = '/home/tra161/WORK/experiments/DS/extraction/XOR/RBM/';

% Load data
data = [0,0,0;
        0,1,1;
        1,0,1;
        1,1,0]';

trn_dat = data(1:end-1,:);
trn_lab = data(end,:);
vld_dat = trn_dat;
vld_lab = trn_lab;

model_f =  strcat(EXP_DIR,'model.mat');
if ~exist(model_f,'file')
conf.hNum   = 4;
conf.sNum   = 0;
conf.bNum   = 0;
conf.eNum   = 50000;
conf.gNum   = 1;
conf.params =  [0.5,0.5,0,0];
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

model.W
model.visB
model.hidB

R = rbm_energy_rank_ext(model,[]);
R.c
R.r

pred_inx = 1;
l = data(pred_inx,:);
data(pred_inx,:) = 0.5;
data
o = confidence_max_sat(R,data,pred_inx);
l
o
