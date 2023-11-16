function [model,...
          max_train_acc_gibbs,...
          max_train_acc_cond,...
          max_eval_acc_gibbs,...
          max_eval_acc_cond,logs] = binary_rbm(conf,trn_dat,trn_lab,val_dat,val_lab)
% Train binary RBM
% Son N. Tran
% sontn.fz@gmail.com

if ~exist('trn_dat','var')  && isfield(conf,'trn_dat_file')
    trn_dat = load_data(conf.trn_dat_file);
end
if ~exist('trn_lab','var') && isfield(conf,'trn_lab_file')
    trn_lab = load_data(conf.trn_lab_file); 
end
if ~exist('val_dat','var') && isfield(conf,'val_dat_file')
    val_dat = load_data(conf.val_dat_file);
end
if ~exist('val_lab','var') && isfield(conf,'val_lab_file')
    val_lab = load_data(conf.val_lab_file);
end

if exist('trn_lab','var'), trn_dat = [trn_dat;trn_lab]; clear trn_lab; ...
        end

[visNum,SZ] = size(trn_dat);
hidNum      = conf.hNum;
sNum        = conf.sNum;
bNum        = conf.bNum;

if sNum==0
    sNum = SZ;
end

if bNum ==0
    bNum = ceil(SZ/sNum);
end

W = (1/max(visNum,hidNum))*randn(visNum,hidNum); % creates a visNum x hidNum matrix of random numbers scaled down
visB = zeros(visNum,1);
hidB = zeros(hidNum,1);

DW = zeros(size(W));
DVB = zeros(size(visB));
DHB = zeros(size(hidB));

lr = conf.params(1);
mm = conf.params(3);
ct = conf.params(4);

running = 1;
epoch = 0;
max_train_acc_gibbs = 0;
max_train_acc_cond  = 0;
max_eval_acc_gibbs  = 0;
max_eval_acc_cond   = 0;
logs = {[],[],[],[],[]};

eval_max = 0;
stop_count = 0;
lr_decay_count= 0;

%%% For XOR grad test
%aconfs = [];
%llhs  = [];
%%%
    
while running && epoch <conf.eNum
    inds = randperm(SZ);
    rec_err = 0;
    epoch = epoch + 1;
    if epoch>conf.ENUM_4_LR_CHANGE, lr = conf.params(2); end 
    for b = 1:bNum
        x = trn_dat(:,(b-1)*sNum + 1:min(b*sNum,SZ)); 
        hidP  = bsxfun(@plus,W'*x,hidB);
        [hidP,hidPs]  = infer(hidP,conf.infer_type);
        hidNs = hidPs;

        for g=1:conf.gNum
            visN  = bsxfun(@plus,W*hidNs,visB);
            [visN,visNs] = infer(visN,conf.infer_type);

            hidN  = bsxfun(@plus,W'*visNs,hidB);
            [hidN,hidNs] = infer(hidN,conf.infer_type);
        end
        rec_err = rec_err + sqrt(sum(mean(visN - x).^2));
        %a = a + mean(visNs(end,:) == x(end,:));
        
        diff = (x*hidP' - visNs*hidN')/sNum;
        DW = lr*(diff - ct*W) + mm*DW;
        W = W + DW;
        DHB = lr*mean(hidP - hidN,2);
        hidB = hidB + DHB;

        if isfield(conf,'use_vis_bias') && conf.use_vis_bias
            DVB = lr*mean(x  - visNs,2);
            visB = visB + DVB;
        end
    end

    if rem(epoch,100) ==0, fprintf('.'); end
    %%% TEST XOR
    %    [llh, agrad, aconf]= xor_llh_and_more(W,hidB)
    %    llhs = [llhs llh];
    %   agrads = [agrads agrad];
    %   aconfs = [aconfs;aconf];
    
    if conf.prediction
        %a/bNum
        [train_acc_gibbs,train_acc_cond] = pre_acc(W,visB,hidB,trn_dat(1:end-1,:),trn_dat(end,:));
        [eval_acc_gibbs,eval_acc_cond]   = pre_acc(W,visB,hidB,val_dat,val_lab);
        fprintf('[Epoch %d] Recon error=%.5f | train acc gibbs = %.5f | train acc cond = %.5f| eval acc gibbs= %.5f| eval acc cond= %.5f\n',epoch,rec_err/bNum,train_acc_gibbs,train_acc_cond,eval_acc_gibbs,eval_acc_cond);

        logs{1} = [logs{1},rec_err/bNum];
        logs{2} = [logs{2},train_acc_gibbs];
        logs{3} = [logs{3},train_acc_cond];
        logs{4} = [logs{4},eval_acc_gibbs];
        logs{5} = [logs{5},eval_acc_cond];
        
        if max_train_acc_gibbs < train_acc_gibbs, max_train_acc_gibbs = ...
                train_acc_gibbs; end
        if max_train_acc_cond < train_acc_cond, max_train_acc_cond = ...
                train_acc_cond; end
        if max_eval_acc_gibbs < eval_acc_gibbs, max_eval_acc_gibbs = ...
                eval_acc_gibbs; end
        if max_eval_acc_cond < eval_acc_cond, max_eval_acc_cond = ...
                eval_acc_cond; end
        eval_max_ = max(eval_acc_gibbs,eval_acc_cond);
        if eval_max_>eval_max 
            eval_max = eval_max_;
            lr_decay_count = 0;
            model.W  = W;
            model.visB = visB;
            model.hidB = hidB;
        else
            lr_decay_count  = stop_count+1;
        end

        if lr_decay_count>conf.lr_decay_num
            lr_decay_count = 0;
            stop_count = stop_count+1;
            lr = lr/1.2;

            W = model.W;
            visB = model.visB;
            hidB = model.hidB;
        end
        if stop_count > conf.early_stop_num || epoch>conf.eNum, ...
                break; end
    else
        fprintf('[Epoch %d] Recon error=%.5f \n',epoch,rec_err/bNum);
    end

    
end

if isfield(conf,'mode_save')
    save(conf.mod_save,'best_W','best_visB','best_hidB')
end
if ~conf.prediction, model.W = W; model.visB = visB; model.hidB = hidB; end

%%%% For xor test
%plotting_xor(llhs,aconfs)
end

%%% TO COMPUTE GRAD FOR XOR
function [llh, agrad, aconf]= xor_llh_and_more(W,hidB)
%mean(abs(W));
pos_data = [1 1 0;
            1 0 1;
            0 1 1;
            0 0 0]';


neg_data = [0 1 0;
            1 0 0;
            0 0 1;
            1 1 1]';
hidI =  bsxfun(@plus,W'*[pos_data neg_data],hidB);
hidIp = 1./(1+exp(-hidI));
px = exp(sum(log(1+exp(hidI))));
px = px./sum(px);

pos_grads = pos_data*hidIp(:,1:4)'/4;

%if epoch==conf.eNum-1
%    hidI'
%    hidIp'
%    pause
%end
grads = bsxfun(@times,[pos_data neg_data],[0.25*ones(1,4) zeros(1,4)] - px)*hidIp';
avg_grad = mean(mean(abs(grads)));

llh = sum(px(1:4));
agrad = avg_grad;
aconf = mean(abs(W));
end

function plotting_xor(llhs,aconfs)
aconfs = bsxfun(@rdivide,aconfs,max(aconfs));
figure;
plot(llhs,'k');
hold on;
plot(aconfs(:,1)','r');
plot(aconfs(:,2)','g');
plot(aconfs(:,3)','b');
plot(aconfs(:,4)','c');

hold off;
legend('likelihood','c_1','c_2','c_3','c_4','Location','SouthEast');
xlabel('Epoches');
end