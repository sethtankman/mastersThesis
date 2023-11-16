function interprete_kinship(data,label,predict,vis,obj_list,pred_list)
obj_num = numel(obj_list);
pred_num = numel(pred_list);
for i=1:size(vis,2)
    % obj1
    obj1 = obj_list{find(data(1:obj_num,i))};
    % obj2
    obj2 = obj_list{find(data(obj_num+1:2*obj_num,i))};
    % target relationship
    pred = find(label(:,i)); pred = pred(mod(pred,2)~=0); pred = ...
           ceil(pred(1)/2);
    rel = pred_list{pred};
    
    rel_ = pred_list{predict};
    fprintf('R(%s, %s) =  %s/%s\n',obj1,obj2,rel,rel_);
    fprintf('Reason:\n');
    % direct relation
    fprintf('Direct:\n');
    [c,inx] = max(vis(1:2*pred_num,i));
    fprintf('%.3f: ',c)
    if mod(inx,2)==0, fprintf('has_'); end
    fprintf('%s\n',pred_list{ceil(inx/2)})
    % possible relations obj1
    fprintf('%s side:\n',obj1);
    for j=1:2*pred_num
        c = vis(2*pred_num+j);
        if c==0,continue; end        
        fprintf('%.3f:',c);
        if mod(j,2)==0, fprintf('has_'); end
        fprintf('%s\n',pred_list{ceil(j/2)});
    end
    % possible relations obj2
    fprintf('%s side:\n',obj2);
    for j=1:2*pred_num
        c = vis(4*pred_num+j);
        if c==0,continue; end        
        fprintf('%.3f: ',c)
        if mod(j,2)~=0, fprintf('has_'); end
        fprintf('%s\n',pred_list{ceil(j/2)})
    end
end
end