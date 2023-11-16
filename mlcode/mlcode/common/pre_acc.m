function [acc_gibbs, acc_cond] = pre_acc(W,visB,hidB,dat,lab)
%prediction for binary rbm
    hidI = bsxfun(@plus,W'*[dat;0.5*ones(1,size(dat,2))],hidB);
    pred_gibbs = 1.0*(W(end,:)*(logistic(hidI)>rand(size(hidI))) > ...
                      0);

    
    hidI0 = bsxfun(@plus,W'*[dat;zeros(1,size(dat,2))],hidB);
    hidI0 = sum(log(1+exp(hidI0)));
   
    hidI1 = bsxfun(@plus,W'*[dat;ones(1,size(dat,2))],hidB);
    hidI1 = sum(log(1+exp(hidI1)));

    [~,pred_cond] = max([hidI0;hidI1],[],1);
    pred_cond = pred_cond-1;
    %pred_gibbs
    %pause
    %lab
    %pause
    acc_gibbs = mean(pred_gibbs==lab);
    acc_cond  = mean(pred_cond ==lab);
end