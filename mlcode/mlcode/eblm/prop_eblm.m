function [model,...
          max_train_acc_gibbs,...
          max_train_acc_cond,...
          max_eval_acc_gibbs,...
          max_eval_acc_cond,logs] = prop_eblm(conf,trn_dat,trn_lab,val_dat,val_lab)
% Train energy based logic models
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

Wr = conf.rules; 
hidBr = -sum(conf.rules(conf.rules>0))+0.5; %%% check this one
rulNum = size(Wr,2);
aNum = hidNum - rulNum;
if aNum<=0, fprintf('Hid num must be larger than rule num\n'); ...
        return; end
cv = conf.initial_cv*ones(1,rulNum);

hidNuma = hidNum - rulNum;
Wa = (1/max(visNum,hidNuma))*randn(visNum,hidNuma);
visB = zeros(visNum,1);
hidBa = zeros(hidNuma,1);

DCV = zeros(size(cv));
DWa = zeros(size(Wa));
DVB = zeros(size(visB));
DHBa = zeros(size(hidBa));

lr = conf.params(1);
ct = conf.params(3);
mm = conf.params(4);

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

if SZ==0 %%% Only rules
    Wrc = bsxfun(@times,Wr,cv);
    hidBrc = hidBr.*cv';
    [eval_acc_gibbs,eval_acc_cond]   = pre_acc(Wrc,visB,hidBrc,val_dat,val_lab)
    max_eval_acc_gibbs = eval_acc_gibbs;
    max_eval_acc_cond  = eval_acc_cond;
    model.W = Wrc;
    model.hidB = hidBrc;
    model.visB = visB;
    return;
end
while running && epoch <conf.eNum
    inds = randperm(SZ); % random permutation of integers from 1 to SZ
    rec_err = 0;
    epoch = epoch + 1;
    if epoch>200, lr = conf.params(2); end
    for b = 1:bNum
        x = trn_dat(:,(b-1)*sNum + 1:min(b*sNum,SZ)); 

        W = [Wa,bsxfun(@times,Wr,cv)]; %%% merging weights
        hidB = [hidBa;hidBr.*cv'];
        %% soft infer
        hidIp  = bsxfun(@plus,W'*x,hidB);
        [hidP,hidPs]  = infer(hidIp,conf.infer_type);
        hidNs = hidPs;

        for g=1:conf.gNum
            visN  = bsxfun(@plus,W*hidNs,visB);
            [visN,visNs] = infer(visN,conf.infer_type);

            hidIn  = bsxfun(@plus,W'*visNs,hidB);
            [hidN,hidNs] = infer(hidIn,conf.infer_type);
        end
        rec_err = rec_err + sqrt(sum(mean(visN - x).^2));
        %a = a + mean(visNs(end,:) == x(end,:));
        
        diffa = (x*hidP(1:aNum,:)' - visNs*hidN(1:aNum,:)')/sNum;
        DWa = lr*(diffa - ct*Wa) + mm*DWa;
        Wa = Wa + DWa;
        DHBa = lr*mean(hidP(1:aNum,:) - hidN(1:aNum,:),2);
        hidBa = hidBa + DHBa;
        %% update cv
        DCV =lr* mean(hidIp(aNum+1:end,:).*hidP(aNum+1:end,:) - hidIn(aNum+1:end,:).*hidN(aNum+1:end,:),2);

        cv = cv + DCV';
        if conf.use_vis_bias %% ignore
            DVB = lr*mean(x  - visNs,2);
            visB = visB + DVB;
        end
    end

    if rem(epoch,100) ==0, fprintf('.'); end
    
    if conf.prediction
        %a/bNum
        W = [Wa,bsxfun(@times,Wr,cv)]; %%% merging weights
        hidB = [hidBa;hidBr.*cv'];
        
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
 
end