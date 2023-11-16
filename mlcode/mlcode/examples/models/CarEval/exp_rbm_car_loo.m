function exp_rbm_car()
eval(strcat(mfilename,'_setting'));
dat = get_data_from_file(dat_file);
lab = get_data_from_file(lab_file);
SZ = size(dat,2);
for trial=1:10
log_file = strcat(EXP_DIR,'gibbs_trial',num2str(trial),'.mat');
for hNum = hNums
for lr = lrs
    acc = [];
    r_evl_acc = [];
    %% leave one out
for cid = 1:size(dat,2) % Leave one out
tic
    trn_inx = setdiff(1:SZ,cid);
    trn_dat = [dat(:,trn_inx);lab(trn_inx)];
    evl_dat = dat(:,cid);
    evl_lab = lab(cid);
    
    conf.hidNum = hNum;
    conf.eNum = 20;
    conf.bNum = 0;
    conf.sNum = 500;
    conf.gNum = 1;
    conf.params = [lr lr 0 0];
    
    conf.class_type = 2;

    model   = gen_discrete_rbm_train(conf,trn_dat,[d_ranges;l_range]);
    
    pred    = predict(model,trn_dat(1:end-1,1),d_ranges,l_range);
    evl_acc = mean(pred==evl_lab);
    acc = [acc evl_acc];
    
    % Extract rules & perform logical inference
    %ext_conf.gen_method = 'EUCLIDEAN_MIN';
    %R = discrete_rbm_ext(ext_conf,model,d_ranges);
    
    %outp = energy_sat_infer(R,disgroup2softmax(evl_dat,d_ranges));
    %r_evl_acc = [r_evl_acc mean(outp == evl_lab)];
    toc
    if rem(cid,50)==0
        fprintf('%d/%d ...\n',cid,size(dat,2))
    end
        
end
fprintf(mean(acc));
%logging(log_file, [lr hNum mean(acc) std(acc) mean(r_evl_acc) std(r_evl_acc)]);
end
end
end

end