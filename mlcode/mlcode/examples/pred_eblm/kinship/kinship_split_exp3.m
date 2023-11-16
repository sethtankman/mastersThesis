%%%%%
% give y and the relationship, predict x that maximises relationship(x,y)
%%%%
clear all;
if ispc
    HOME = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
    HOME = getenv('HOME');
end

addpath(genpath(strcat(HOME,'/WORK/projects/DeepSymbolic/code')));
EXP_DIR = strcat(HOME,['/WORK/experiments/DS/eblm/Kinship_split_exp3/' ...
                    'encode_ae/']);
if ~exist(EXP_DIR,'dir'), mkdir(EXP_DIR); end
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
%conf.ae_share_weights = 0;
conf.pred_infer_type = 'stochastic';
conf.rule_infer_type = 'stochastic';
conf.gibbs_rule_inf_type='split';

if isfield(conf,'ae_share_weights') && conf.ae_share_weights == 0
    EXP_DIR = strrep(EXP_DIR,'encode_ae','encode_ae_noshare');
end

if ~exist(EXP_DIR,'dir'), mkdir(EXP_DIR); end

model_save = 'model.mat';
N = 30;
for trial = 1:5
trn_inds = randperm(size(rules,1));
tst_inds = trn_inds(end-N+1:end);
trn_inds = trn_inds(1:end-N);
tst_rules = rules(tst_inds,:);
trn_rules = rules(trn_inds,:);
trn_dat = data(1:2*obj_num,trn_inds);
trn_lab = data(2*obj_num+1:end,trn_inds); 
vld_dat = data(1:2*obj_num,tst_inds);
vld_lab = data(2*obj_num+1:end,tst_inds);

obj_lab = {};
for i=1:size(vld_dat,2)
    obj2 = find(vld_dat(obj_num+1:2*obj_num,i));
    pred = find(vld_lab(:,i)); pred = pred(mod(pred,2)~=0); pred = ceil(pred(1)/2);
    obj1s = [];
    for j = 1:size(data,2)
        obj2_ = find(data(obj_num+1:2*obj_num,j));
        pred_ = find(data(2*obj_num+1:end,j)); pred_ = pred_(mod(pred_,2)~=0); pred_ = ceil(pred_(1)/2);
        if obj2 == obj2_ && pred == pred_
            obj1s = [obj1s,find(data(1:obj_num,j))];
        end
    end
    obj_lab = [obj_lab,obj1s];
end
    
for hidNum = [50,100,200]
conf.clause_h_num = hidNum;
for lr = [0.001,0.01,0.1,0.5,0.9]
conf.params(1)=lr;
conf.params(2)=lr;
for cv = [0.01,0.1,0.5,1,3,5,9]
    conf.initial_cv = cv;
    log_file = strcat(EXP_DIR,'rs_N',num2str(N),'_h',num2str(hidNum),...
                      '_lr',num2str(lr),'_cv',num2str(cv),...
                      '_trial',num2str(trial),'.mat');        
    if ~(exist(model_save,'file') || exist(log_file,'file'))
        %model = pred_eblm(conf,trn_rules,trn_dat,trn_lab);
        model = kinship_eblm(conf,trn_rules,trn_dat,trn_lab);
        %save(model_save,'model')
    else
        continue;
        load(model_save);
    end
    % Reasoning
    rs = [];
    for i = 1:size(vld_dat,2)
        in_  = [eye(obj_num);repmat(vld_dat(obj_num+1:2*obj_num,i),[1,obj_num])];        
        lab_ = repmat(vld_lab(:,i),[1,obj_num]);
        [~,out,~] = pred_eblm_infer(conf,model,in_,pred_num);
        out = out(1:2*pred_num,:);
        %out(1:2:2*pred_num,:)
        
        vld_lab_ = find(vld_lab(:,i));
        rel = vld_lab_(mod(vld_lab_,2)~=0); rel = rel(1);
        o1 = find(vld_dat(1:obj_num,i));


        out(2:2:size(out,1),:) = 0;
        [a,rank] = sort(out(rel,:),'descend');
        %ceil(rel/2)
        %[sort(rank(1:numel(obj_lab{i})))',sort(obj_lab{i})']
        %pause
        if sum(sum(sort(rank(1:numel(obj_lab{i})))~=sort(obj_lab{i})))==0        
            rs = [rs,1];
        else
            rs = [rs,0];
        end
        %rs
    end
    save(log_file,'rs');
end
end
end
end