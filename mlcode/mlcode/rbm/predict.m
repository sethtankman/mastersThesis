function [gibb_pred, cond_pred] = predict(model,dat,dat_ranges,lab_range)
%% Prediction with Gibbs sampling
%dat
dat = disgroup2softmax(dat,dat_ranges);
%size(dat)
inpdat = [dat;0.5*ones(lab_range,size(dat,2))];
units
up = vis2hid(bsxfun(@plus,model.W'*inpdat,model.hidB));
up = hid_sample(up);
down = bsxfun(@plus,model.W*up,model.visB);
gibb_pred = down(end-dat_ranges(end)+1:end,:);
[~,gibb_pred] = max(gibb_pred,[],1);
%% Prediction with free energy
model.U = model.W(end-lab_range+1:end,:);
model.W = model.W(1:sum(dat_ranges),:);
hidNum = size(model.W,2);
sNum = size(dat,2);
lNum = lab_range;

%size(dat)
%size(model.W)
%size(model.U)
%pause
xxxx = repmat(model.W'*dat + repmat(model.hidB,1,sNum),[1,1,lNum]) + ...
        repmat(reshape((model.U'*eye(lNum)),[hidNum,1,lNum]),[1,sNum,1]);   
xxxx = reshape(sum(log(1+exp(xxxx)),1),[sNum lNum]);
[~,outp] = max(xxxx,[],2);    
cond_pred = outp';
end