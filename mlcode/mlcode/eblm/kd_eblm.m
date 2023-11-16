function kd_eblm()
%%%%%%% Preparing mask
visNum = x_p(end,end);
hidNum = h_c(end,end);

mask   = zeros(visNum,hidNum);
% set masks for possible grounding objects
mask(1:x_v(end,end),1:h_p(end,end)) = 1;
% set masks for each predicates
assert(size(x_p)==size(h_p),'predicate encoding mistmach');
for i = 1:size(x_p,2)
    mask(x_p(i,1):x_p(i,2),h_p(i,1):h_p(i,2)) = 1;
end
% set masks for clauses (this version assumes clauses are unknown)
mask(x_p(0,0):x_p(end,end),h_c(0,0):h_c(end,end))=1;

%%%%% Initialise
SZ = size(data,2);
sNum        = conf.sNum;
bNum        = conf.bNum;

if sNum == 0
    sNum = SZ;
end

if bNum = 0
    bNum = ceil(SZ/sNum);
end

W = ((1/max(visNum,hidNum))*randn(visNum,hidNum)).*mask;
visB = zeros(visNum,1);
hidB = zeros(hidNum,1);

DW = zeros(size(W));
DVB = zeros(size(visB));
DHB = zeros(size(hidB));

lr = conf.params(1);
ct = conf.params(3);
mm = conf.params(4);


for epoch=1:conf.eNum
    inds = randperm(SZ);
    rec_err = 0;
    if epoch>200, lr = conf.params(2); end 
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
        
        diff = (x*hidP' - visNs*hidN')/sNum;
        DW = lr*(diff - ct*W) + mm*DW;
        W = W + DW.*mask;
        DHB = lr*mean(hidP - hidN,2);
        hidB = hidB + DHB;

        if conf.use_vis_bias
            DVB = lr*mean(x  - visNs,2);
            visB = visB + DVB;
        end
    end
    if rem(epoch,100) ==0, fprintf('.'); end

    if conf.prediction
        fprintf('TODO');
    else
        fprintf('[Epoch %d] Recon error=%.5f \n',epoch,rec_err/bNum);
    end
    
end
end