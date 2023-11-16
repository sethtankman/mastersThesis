function [out,vis_,vis] =  pred_eblm_infer(conf,model,dat_,pred_num)
%   First logical infer
%%% NOTE: lab_ is only used for getting the size of predicates
obj_num = size(dat_,1)/2;

dat_ = [dat_;ones(2*pred_num,size(dat_,2))];

vis = gibbs_rule_infer(conf,dat_,model.rule_model.Wr, ...
                       model.rule_model.cv,model.rule_model.hidBr,obj_num);

vis = (vis-model.rule_model.MN)/(model.rule_model.MX-model.rule_model.MN);

if strcmp(conf.pred_model_type,'rbm')
    for g=1:conf.gNum
        hidI  = bsxfun(@plus,model.pred_model.W'*vis,model.pred_model.hidB);
        [hid,hids]  = infer(hidI,conf.pred_infer_type);
        
        vis_  = bsxfun(@plus,model.pred_model.W*hid,model.pred_model.visB);
        [vis_,viss] = infer(vis_,conf.pred_infer_type);        
    end
elseif strcmp(conf.pred_model_type,'ae')
    
    if ~isfield(conf,'ae_share_weights') || conf.ae_share_weights
        h  = 1./(1+exp(-bsxfun(@plus,model.pred_model.We'*vis,model.pred_model.hidB)));
        vis_ = 1./(1+exp(-bsxfun(@plus,model.pred_model.Wd'*h, ...
                                model.pred_model.visB)));
    else
        h  = tanh(bsxfun(@plus,model.pred_model.We'*vis,model.pred_model.hidB));
        vis_ = 1./(1+exp(-bsxfun(@plus,model.pred_model.Wd'*h, ...
                                model.pred_model.visB)));
    end
end

[~,out] = sort(vis(1:2*pred_num,:),'descend');

end