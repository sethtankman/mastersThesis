function exp_rbm_car()
eval(strcat(mfilename,'_setting'));
dat = get_data_from_file(dat_file);
lab = get_data_from_file(lab_file);
SZ = size(dat,2);
for trial=1:10
    log_file = strcat(EXP_DIR,'gibbs_trial',num2str(trial),'.mat');
for lr = [0.001 0.01 0.1]
    acc = [];
    r_evl_acc = [];
    
    conf.hidNum = 500;
    conf.eNum   = 1000;
    conf.bNum   = 0;
    conf.sNum   = 0;
    conf.gNum   f= 1;
    conf.params = [lr lr 0 0];

    conf.use_vis_bias = 0;
    
    model   = gen_discrete_rbm_train(conf,[dat;lab],[d_ranges;l_range]);
    
    [g_pred,c_pred] = predict(model,dat,d_ranges,l_range);
    g_acc     = mean(g_pred==lab);
    c_acc    = mean(c_pred==lab);
    
    % Extract rules & perform logical inference
    %ext_conf.gen_method = 'EUCLIDEAN_MIN';
    %R = discrete_rbm_ext(ext_conf,model,d_ranges);
    
    %outp = energy_sat_infer(R,disgroup2softmax(evl_dat,d_ranges));
    %r_evl_acc = [r_evl_acc mean(outp == evl_lab)];
    logging(log_file, [lr conf.hidNum g_acc c_acc]);
end
end

end