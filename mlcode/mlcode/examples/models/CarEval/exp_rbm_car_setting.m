%%% Project setting %%%
PRJ_DIR= '~/WORK/experiments/DS/extraction/Car/';    
addpath(genpath('~/WORK/projects/DeepSymbolic/code/'));
DAT_DIR  = '~/WORK/projects/DeepSymbolic/data/Car/';
lm = '/';
    
hNums = [100 500 1000 2000];
lrs = [0.0001 0.001 0.01 0.1 0.3 0.5];


EXP_DIR = strcat(PRJ_DIR,'RBM',lm);

dat_file = strcat(DAT_DIR,'car_trn_dat');
lab_file = strcat(DAT_DIR,'car_trn_lab');

if ~exist(EXP_DIR,'dir'), mkdir(EXP_DIR); end

d_ranges = [4;4;4;3;3;3];
l_range = 4;