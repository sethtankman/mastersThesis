function model = auto_encoder(conf,trn_dat)
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

We = (1/max(visNum,hidNum))*randn(visNum,hidNum); % encode weights
Wd = (1/max(visNum,hidNum))*randn(hidNum,visNum); % decode weights
visB = zeros(visNum,1);
hidB = zeros(hidNum,1);

DWe = zeros(size(We));
DWd = zeros(size(Wd));
DVB = zeros(size(visB));
DHB = zeros(size(hidB));

lr = conf.params(1);
ct = conf.params(3);
mm = conf.params(4);
epoch  = 0;
rec_err = 0;
share_weights=1;
if isfield(conf,'ae_share_weights'), share_weights = conf.ae_share_weights; end

while epoch <conf.eNum
    inds = randperm(SZ);
    rec_err = 0;
    epoch = epoch + 1;
    if epoch>conf.ENUM_4_LR_CHANGE, lr = conf.params(2); end 
    for b = 1:bNum
        x = trn_dat(:,(b-1)*sNum + 1:min(b*sNum,SZ));
        b_size = size(x,2);
        if share_weights
            Wd = We';              
            % forward
            h  = 1./(1+exp(-bsxfun(@plus,We'*x,hidB)));
            x_ = 1./(1+exp(-bsxfun(@plus,Wd'*h,visB)));

            rec_err = rec_err + sqrt(sum(mean(x_ - x).^2));
  
            vdiff = (x - x_);
            hdiff = (We'*vdiff).*h.*(1-h);
            wdiff = (x*hdiff' + vdiff*h');% divided by batch_size
                                          % results will need large
                                          % learning rate 

            DWe = lr*(wdiff/sNum-ct*We) + ...
                   mm*DWe;
            We = We + DWe;

            DVB = lr*mean(vdiff,2) + mm*DVB;
            visB = visB +DVB;

            DHB = lr*mean(hdiff,2) + conf.params(3)*DHB;
            hidB  = hidB + DHB;
        else
            h  = tanh(bsxfun(@plus,We'*x,hidB));
            x_ = 1./(1+exp(-bsxfun(@plus,Wd'*h,visB)));
            
            truth = x; truth(x~=1)=0;
            
            rec_err = rec_err + sqrt(sum(mean(x_ - truth).^2));
            % back-prop
            err  = (truth-x_).*(x_.*(1-x_));
            diff = h*err'/b_size;
            DWd  = lr*(diff-ct*DWd)+mm*DWd;
            Wd   = Wd + DWd;
            DVB  = lr*mean(err,2) + mm*DVB;
            visB = visB+DVB;
            
            err  = (Wd*err).*(1-h.^2);
            diff = x*err'/b_size;
            DWe  = lr*(diff-ct*DWe)+mm*DWe;
            We   = We + DWe; 
            DHB  = lr*mean(err,2) + mm*DHB;
            hidB = hidB + DHB;           
        end
    end
    epoch = epoch + 1;
    if rem(epoch,5000)==0, fprintf('[Epoch %.4d]: Err = %.5f\n', ...
                                   epoch,rec_err/bNum); end
end
model.We = We;
model.hidB = hidB;
model.visB = visB;
if share_weights
    model.Wd = We';
else
    model.Wd = Wd;
end
end