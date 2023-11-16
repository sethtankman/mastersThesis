function [model]= pred_eblm(conf,rules,trn_dat,trn_lab,vld_dat,vld_lab)
%
% This version is to test with kinship
%

%%%%%%% Define structure
x_v = [];  % indices of visible units for  objects
x_p = [];  % indices of visible units for predicates
h_p = [];  % indices of hidden units for  predicates


Wr    = []; % weight matrix for rules
hidBr = []; % hidden biases for rules
visBr = []; % not used
%%%%%%% Initialize
trn_dat = [trn_dat;trn_lab];
visNum = size(trn_dat,1);
pred_num = conf.predicate_num;
obj_num  = conf.object_num;
visNump  = visNum - 2*obj_num;

x_v = [[1,obj_num];...
       [obj_num+1,2*obj_num]];
x_p = 2*obj_num+ reshape(1:2*pred_num,[2,pred_num])';

% set masks for predicates
if ~isempty(rules)
    h_p_start = 0;
    h_p_end   = 0;
    for pred_inx = 1:pred_num
        rs = rules(rules(:,3)==pred_inx,:);
        if ~isempty(rs) && size(rs,1)>0
            h_p_start = h_p_start+1;
        end
        for i =1:size(rs,1)
            %r[1]: object 1, r[2]: object 2, r[3]: pred_index (in pred_list)
            r = rs(i,:);
            w = zeros(visNum,1);
            w(r(1)) = 1; 
            w(obj_num+r(2))=1;
            w(2*obj_num+2*(r(3)-1)+1) = 1;
            Wr = [Wr,w];
            
            w = zeros(visNum,1);
            w(r(2)) = 1;
            w(obj_num+r(1))=1;
            w(2*obj_num+2*(r(3)-1)+2) = 1;
            Wr = [Wr,w];

            h_p_end = h_p_end+2;
        end
        if h_p_end>h_p_start
            h_p = [h_p;[h_p_start,h_p_end]];            
        end
        h_p_start = h_p_end;
    end
end

hidNumr = size(Wr,2);
hidBr = (-sum(Wr>0)+0.5)';
cv    = conf.initial_cv*ones(1,hidNumr);
%%%% Gibbs sampling on confidence-rules
dat_ = trn_dat;
dat_(2*obj_num+1:end,:)  = 1;
Wrc = bsxfun(@times,Wr,cv);

hidI  = bsxfun(@plus,Wrc'*dat_,hidBr.*cv');
[hid,hids]  = infer(hidI,conf.rule_infer_type);
%unique(hid)
vis=[];
for p = 1:visNump
    wrc = Wrc(2*obj_num+p,:);
    vis = [vis;max(bsxfun(@times,hid,wrc'))];
end
%unique(vis(:))
[vis,viss] = infer(vis,conf.rule_infer_type);

MN = min(vis(:));
MX = max(vis(:));
vis = (vis-MN)/(MX-MN);
%vis()
%pause
dat_ = vis;
%% unsupervised learning to link predicates
conf_ = conf;
conf_.hNum = conf.clause_h_num;
conf_.prediction = 0;
if isfield(conf,'infertype')
    conf_.infer_type = conf.pred_infer_type;
else
    conf_.infer_type = 'stochastic';
end

pred_model  = train_linked_predicates(conf_,dat_,conf.pred_model_type);
% pred_model  = train_relationship(conf_,dat_,conf.pred_model_type);

if isfield(conf,'mode_save')
    save(conf.mod_save,'best_W','best_visB','best_hidB')
end

rule_model.Wr    = Wr;
rule_model.hidBr = hidBr;
rule_model.cv    = cv;
rule_model.x_v   = x_v;
rule_model.x_p   = x_p;
rule_model.h_p   = h_p;
rule_model.MN = MN;
rule_model.MX =MX;

model.rule_model = rule_model;
model.pred_model = pred_model;

end

function pred_model= train_linked_predicates(conf,data,type)
%% Train the linked predicate part
    if strcmp(type,'rbm')
        pred_model = binary_rbm(conf,data);
    elseif strcmp(type,'ae')
        pred_model = auto_encoder(conf,data);
    end
end



