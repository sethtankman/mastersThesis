if isfield(conf,'E_STOP')
        if vld_acc<=vld_best
            acc_drop_count = acc_drop_count + 1;
            % If accuracy reduces for a number of time, then turn back to the
            % best model and reduce the learning rate
            if isfield(conf,'E_STOP_LR_REDUCE') && acc_drop_count > conf.E_STOP_LR_REDUCE
                fprintf('Learning rate reduced!\n');
                acc_drop_count = 0;
                es_count = es_count + 1; %number of reduce learning rate
                lr = lr/10;
                model = model_best;
            end            
        else
            es_count = 0;
            acc_drop_count = 0;
            vld_best = vld_acc;
            tst_best = tst_acc;
            model_best = model;
        end
    end
    % Early stopping
    if isfield(conf,'E_STOP') 
        if isfield(conf,'desire_acc') && vld_acc >= conf.desire_acc, running=0;end
        if es_count > conf.E_STOP, running=0; end
    end