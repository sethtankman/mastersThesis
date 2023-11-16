function vis = gibbs_rule_infer(conf,inp,Wr,cv,hidBr,obj_num)
    if isfield(conf,'gibbs_rule_inf_type') && strcmp(conf.gibbs_rule_inf_type,'split')
        dat_ = inp;
        dat_(2*obj_num+1:end,:)  = 1;
        Wrc = bsxfun(@times,Wr,cv);
        %% Split down inference
        %1- infer direct relation btween obj1 & obj2
        hidI  = bsxfun(@plus,Wrc'*dat_,hidBr.*cv');
        [hid,hids]  = infer(hidI,conf.rule_infer_type);
        hid(hidI<=0) = 0;
        vis1 = gibbs_rule_down(hid,Wrc,obj_num,conf);
        %2- infer possible relations of obj1
        % TODO NEXT: how to remove possible relation with obj2
        hidI = bsxfun(@plus,Wrc(1:obj_num,:)'*dat_(1:obj_num,:) ...
                      + Wrc(2*obj_num+1:end,:)'*dat_(2*obj_num+1:end,:),...
                      hidBr.*cv');
        [hid,hids]  = infer(hidI,conf.rule_infer_type);
        hid(hid==min(hid(:)))=0;
        vis2 = gibbs_rule_down(hid,Wrc,obj_num,conf);
        %3- infer possible relations of obj2
        % TODO NEXT: how to remove possible relation with obj1
        hidI = bsxfun(@plus,Wrc(obj_num+1:2*obj_num,:)'*dat_(obj_num+1:2*obj_num,:) ...
                      + Wrc(2*obj_num+1:end,:)'*dat_(2*obj_num+1:end,:),...
                      hidBr.*cv');
        [hid,hids]  = infer(hidI,conf.rule_infer_type);
        hid(hid==min(hid(:)))=0;
        vis3 = gibbs_rule_down(hid,Wrc,obj_num,conf);
        
        %%%% merging
        vis = [vis1;vis2;vis3];
    else
        dat_ = inp;
        dat_(2*obj_num+1:end,:)  = 1;
        Wrc = bsxfun(@times,Wr,cv);
        
        hidI  = bsxfun(@plus,Wrc'*dat_,hidBr.*cv');
        [hid,hids]  = infer(hidI,conf.rule_infer_type);
        %unique(hid)
        vis =  gibbs_rule_down(hid,Wrc,obj_num,conf);
    end

end

function vis = gibbs_rule_down(hid,Wrc,obj_num,conf)
    vis=[];
    for p = 1:size(Wrc,1)-2*obj_num
        wrc = Wrc(2*obj_num+p,:);
        vis = [vis;max(bsxfun(@times,hid,wrc'))];
    end
    %unique(vis(:))
    [vis,viss] = infer(vis,conf.rule_infer_type);
end