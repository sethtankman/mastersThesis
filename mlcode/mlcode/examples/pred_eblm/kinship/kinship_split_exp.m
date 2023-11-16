%%%%%
% give x,y predict relationship(x,y)
%%%%
clear all;
if ispc
    HOME = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
    HOME = getenv('HOME');
end

addpath(genpath(strcat(HOME,'/WORK/projects/DeepSymbolic/code')));
EXP_DIR = strcat(HOME,'/WORK/experiments/DS/eblm/Kinship_split/encode_ae/');
clau_h_num = 200; % number of hidden unit for clauses

x_v = [];  % indices of visible units for  objects
x_p = [];  % indices of visible units for predicates
h_p = [];  % indices of hidden units for  predicates
h_c = [];  % indices of hidden units for clauses

%% load data
[pred_list,obj_list,data,rules] = kinship_data();

%% construct model's structure
pred_num = numel(pred_list);
obj_num  = numel(obj_list);

%% learning
conf.sNum = 0;
conf.bNum = 0;
conf.gNum = 1;
conf.eNum = 10000;
conf.params = [0.9,0.1,0.0000,0];
conf.ENUM_4_LR_CHANGE = 50000;

conf.clause_h_num = clau_h_num; % number of hidden for clause
conf.object_num = obj_num;
conf.predicate_num = pred_num;
conf.initial_cv = .5;
conf.pred_model_type = 'ae';
conf.ae_share_weights = 0;
conf.pred_infer_type = 'stochastic';
conf.rule_infer_type = 'stochastic';
conf.gibbs_rule_inf_type = 'split';

if isfield(conf,'ae_share_weights') && conf.ae_share_weights == 0
    EXP_DIR = strrep(EXP_DIR,'encode_ae','encode_ae_noshare');
end

if ~exist(EXP_DIR,'dir'), mkdir(EXP_DIR); end
model_save = 'model.mat';
for trial = 1:1
for hidNum = [100]
conf.clause_h_num = hidNum;
for lr = [0.5]
conf.params(1)=lr;
conf.params(2)=lr;
for cv = [5]
    conf.initial_cv = cv;
    log_file = strcat(EXP_DIR,'rs_h',num2str(hidNum),...
                      '_lr',num2str(lr),'_cv',num2str(cv),...
                      '_trial',num2str(trial),'.mat');
    rs = [];
    for i = 1:size(rules,1)
        trn_inds = setdiff(1:size(rules,1),i);   
        tst_rules = rules(i,:);
        trn_rules = rules(trn_inds,:);
        trn_dat = data(1:2*obj_num,trn_inds);
        trn_lab = data(2*obj_num+1:end,trn_inds);
        vld_dat = data(1:2*obj_num,i);
        vld_lab = data(2*obj_num+1:end,i);
        
        if ~(exist(model_save,'file') || exist(log_file,'file'))
            model = kinship_eblm(conf,trn_rules,trn_dat,trn_lab);
            %save(model_save,'model')
        else
            continue;
            load(model_save);
        end
        % Reasoning
        [out,vis_,vis] = pred_eblm_infer(conf,model,vld_dat,pred_num);
        [~,predict] = max(vis_(1:2:2*pred_num));
        interprete_kinship(vld_dat,vld_lab,predict,vis,obj_list, ...
                           pred_list);
        for k=1:pred_num
            fprintf('%.3f:%s ', vis_(2*(k-1)+1),pred_list{k});            
        end
        fprintf('\n');
        
        %pred = out(mod(out,2)~=0); pred = pred(1);
        crr = find(vld_lab);
        crr = crr(mod(crr,2)~=0); crr = ceil(crr(1)/2);
       
        %[pred,crr]
        rs = [rs,predict==crr];
       
    end
    rs
    save(log_file,'rs');
    pause
end
end
end
end