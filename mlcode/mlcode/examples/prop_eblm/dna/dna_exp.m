clear all;
if ispc
    HOME = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
    HOME = getenv('HOME');
end

addpath(genpath(strcat(HOME,'/WORK/projects/DeepSymbolic/code')));
EXP_DIR = strcat(HOME,'/WORK/experiments/DS/eblm/DNA');

[dat,lab] = dna();
%size(dat)
%size(lab)
%lab
%%% save to file
csvwrite(strcat(HOME,'/WORK/Data/ILP/BC/dna.csv'),[dat;lab]')


%N =80;
%trn_dat = dat(:,1:N);
%trn_lab = lab(1:N);
%vld_dat = dat(:,N+1:end);
%vld_lab = lab(N+1:end);

rules = dna_theory();
rules
size(rules)
return 
for trial=1:10
    for snum = [10,20,30,40,50,60,70,80,90]
        EXP_DIR = strcat(EXP_DIR,num2str(snum));
        if ~exist(EXP_DIR,'dir'),mkdir(EXP_DIR); end
        trn_dat = dat(:,1:snum);
        trn_lab = lab(1:snum);
        vld_dat = dat(:,snum+1:end);
        vld_lab = lab(snum+1:end);

        for hNum = [100,500,1000]
            for lr = [0.1,0.3,0.5,0.7,0.9]
                if snum==0 && ~(hNum==50 && lr==0.1), continue; end
    
                log_file = strcat(EXP_DIR,'/log_hNum',num2str(hNum),'_lr', ...
                      num2str(lr),'_trial',num2str(trial));
                if exist(log_file,'file'), continue; end
                conf.hNum   = hNum;
                conf.sNum   = 0;
                conf.bNum   = 0;
                conf.eNum   = 500;
                conf.gNum   = 1;
                conf.params =  [lr,lr,0,0];
                conf.ENUM_4_LR_CHANGE = 100;
                conf.use_vis_bias = 0;
                conf.prediction = 1;
                conf.lr_decay_num = 1000000;
                conf.early_stop_num = 100000;
            
                conf.infer_type = 'stochastic';
            
                rs = [];
            
                if snum==0
                    ev_ = max(mean(vld_lab==0),mean(vld_lab==1));
                    cd_=ev_;
                else
                    [~,~,~,ev_,cd_,~] = binary_rbm(conf,trn_dat,trn_lab,vld_dat, ...
                                                   vld_lab);
                end

                rs = [rs,[ev_;cd_;0]];
                for cv = [0.01,0.1,0.5,1,2,5]
                    conf.initial_cv = 10;
                    conf.rules = [rules;ones(1,size(rules,2))]*2-1;
                    [~,~,~,ev_,cd_,~] = prop_eblm(conf,trn_dat,trn_lab,vld_dat, ...
                                                  vld_lab);
                    rs = [rs,[ev_;cd_;cv]];
                    %plot(logs{5});
                    %legend('w.o','w.');
                    %saveas(gcf,'test.png');
                    %hold off;    
                end
                fprintf('saving log to %s\n',log_file);
                save(log_file,'rs');
            end
        end
    end
end