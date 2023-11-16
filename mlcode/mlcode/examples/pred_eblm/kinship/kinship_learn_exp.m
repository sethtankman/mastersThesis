clear all;
addpath(genpath('/home/tra161/WORK/projects/DeepSymbolic/code'));
pred_h_num = 10; % number of hidden unit fr each predicate
clau_h_num = 10; % number of hidden unit for clauses

x_v = []; % visible indices for variables
x_p = []; % visible indices for predicates
h_p = []; % hidden indices  for predicates
h_c = []; % hidden indices for clauses


%% load data
[pred_list,obj_list,data] = kinship_data();
%% construct model's structure
pred_num = numel(pred_list);
obj_num  = numel(obj_list);
x_v = [[1,obj_num];...
       [obj_num+1,2*obj_num]];
x_p = 2*obj_num+ reshape(1:2*pred_num,[2,pred_num])';
h_p = [1:pred_h_num:pred_h_num*(pred_num-1)+1;...
       pred_h_num:pred_h_num:pred_h_num*pred_num]';
h_c = [pred_h_num*pred_num+1,pred_h_num*pred_num+clau_h_num];

%x_v
%x_p
%h_p
%h_c

%% learning

conf.params = [0.1,0.1,0,0];
model = pred_eblm(conf,x_v,x_p,h_p,h_c,data);

%% reasoning




