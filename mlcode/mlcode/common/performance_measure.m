function [confusion,acc,av_prec,av_recall,av_f1] = performance_measure(output,labels,flag)
% Measure the performance
% Son T

if nargin<3, flag='micro'; end

ls = unique(labels);
confusion = confusionmat(labels,output); 
if strcmp(flag,'micro')    
    % (TP1+TP2 ...)/(TP1 + FP1 + TP2+ FP2...)
    TPa = sum(diag(confusion));
    av_prec = TPa/sum(confusion(:)); % In this case it equal to accuracy
    av_recall = TPa/sum(confusion(:));
    av_f1 =2*(av_prec*av_recall)/(av_prec+av_recall);
elseif strcmp(flag,'macro')    
    prec = diag(confusion)'./sum(confusion);
    recall = diag(confusion)./sum(confusion,2);
    av_prec   = mean(prec);
    av_recall = mean(recall');
    av_f1 =mean(2*(av_prec.*av_recall)./(av_prec+av_recall));
else
    fprintf('Flag is not supported\n');
end
acc = sum(output==labels)/size(labels,1);
end

