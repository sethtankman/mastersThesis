clear all
close all
%function [NAMAC_recommend,input_diag] = NAMAC_v2(t_acc,t_recmd)
t_acc=0;%time at which the accident is injected
t_recmd=5;%time unitil which NAMAC collects sensor data
constraints = 685;%safety constraint for strategy assessment
p2_nominal = 91.55; %rad/s

name_datafile9 = 'histories_short_print_400.csv';


tab = readtable(name_datafile9);
%Plot the data file
figure; plot(tab.time,tab.PS1);hold on; plot(tab.time,tab.PS2);
xlabel('time (s)')
ylabel('Pump speed (rad/s)')
legend('PS1','PS2');figure; plot(tab.time, tab.TA21s1)
xlabel('time (s)')
ylabel('Fuel Centerline temperature (C)')
time=tab.time;
TL14=tab.TL14s1;
TL9=tab.TL9s1;
TL8=tab.TL8s1;
TA1s5=tab.TA21s1;

[val_trans,pos_trans] = min(abs(time-t_acc));
[val_diag,pos_diag] = min(abs(time-t_recmd));
val_end = time(end);

% val_diag = min(val_diag,val_end);
pos_diag = min(pos_diag,length(time));

HP_LP_diag = TL8(pos_trans:pos_diag);  
LP_LP_diag = TL9(pos_trans:pos_diag);
UP_diag = TL14(pos_trans:pos_diag);
FCL_obs = TA1s5(pos_trans:pos_diag);
time_diag = time(pos_trans:pos_diag);

% total length of input sensory
len_diag = pos_diag-pos_trans+1;
% half of the total length
len_h_diag = round(len_diag/2);

load('DT_Diagnosis.mat','net');
model_diag = net;                  % load the trained diagnosis engine
input_diag = [HP_LP_diag,LP_LP_diag,UP_diag]';    % assemble diagnosis inputs
FCL_diag = model_diag(input_diag); % predicted diagnosis
FCLT_dt1_diagnosis = (FCL_diag(end)-FCL_diag(end-1))/(time_diag(end)-time_diag(end-1));
FCLT_dt5_diagnosis = (FCL_diag(end)-FCL_diag(len_h_diag))/(time_diag(end)-time_diag(len_h_diag));
FCLT_dt10_diagnosis = (FCL_diag(end)-FCL_diag(1))/(time_diag(end)-time_diag(1));
%%
figure
plot(time_diag-t_acc,FCL_diag,'k.-')
hold on
plot(time_diag-t_acc,FCL_obs,'r.-')
hold off
xlabel('time (sec)'),ylabel('peak fuel centerline temperature')
legend('Diagnosis Predicted','GSIM outputs')
%%

load('triptemperature_to_time.mat','net')
model_trip_time = net;

% filename2 = 'DT_Strategy_Inventory.csv';
% control_opt = csvread(filename2,1,0);
% read pump #2 control options from knowledge base
% p2_input_opt = control_opt(:,2);  
% %read trip time options (equivalent to trip temperature, not used here)
% time_trip_opt = control_opt(:,1); 
% %read trip temperature options
% T_trip_opt = control_opt(:,3); 

p2_input_opt = linspace(91,137.5,32)';
T_trip_opt = linspace(FCL_diag(end),685,32)';
time_ref = model_trip_time(FCL_diag(end));

%find available options based on diagnosed TFCL
Av_opt_diagnosis = T_trip_opt>FCL_diag(end); 
if sum(Av_opt_diagnosis)==0
    sprintf('no available action found in the inventory')
    NAMAC_recommend = nan;
else
    T_trip_opt_diagnosis = T_trip_opt(Av_opt_diagnosis);
    p2_input_opt_diagnosis = p2_input_opt(Av_opt_diagnosis);
    num_opt_diagnosis = sum(Av_opt_diagnosis);
    
    %%
    load('DT_Prognosis.mat','net');
    model_prognosis = net;  % load the trained prognosis engine
    
    %%
    [T_mesh,p2_input_mesh] = meshgrid(T_trip_opt,p2_input_opt);
    [d1,d2] =  size(T_mesh);
    
    for i = 1:d1
        for j = 1:d2
            inputs  = [FCL_diag(1);FCLT_dt1_diagnosis;FCLT_dt5_diagnosis;...
                FCLT_dt10_diagnosis;T_mesh(i,j);p2_input_mesh(i,j)];
            output_prognosis_diagnosis(i,j) = sim(model_prognosis,inputs);
            time_matrix(i,j) = sim(model_trip_time,T_mesh(i,j))-time_ref;
        end
    end
    NAMAC_margin = constraints-output_prognosis_diagnosis;
    
    NAMAC_satisfied_action = NAMAC_margin>0;
    num_NAMAC = sum(NAMAC_satisfied_action,'all');
    header = {'safe','pump#2_action',...
        'trip_temperature','trip_time','predicted PFCL','margin'}.';
    fid = fopen('NAMAC_recommendation\result.dat','wt');
    fprintf(fid,'%s %s %s %s %s %s\n',header{:});
    fprintf(fid,'%d %f %f %f %f %f \n',[NAMAC_satisfied_action(:),...
        p2_input_mesh(:),T_mesh(:),time_matrix(:),...
        output_prognosis_diagnosis(:),NAMAC_margin(:)].');
    fclose(fid);
    
    if num_NAMAC == 0
        sprintf('no satisfied action can be found, suggest to SCRAM')
        NAMAC_recommend = nan;
    else
        T_trip_NAMAC_satisfied = T_mesh(NAMAC_satisfied_action);
        time_trip_NAMAC_satisfied = time_matrix(NAMAC_satisfied_action);
        p2_input_NAMAC_satisfied = p2_input_mesh(NAMAC_satisfied_action)';
        p2_input_fraction_satisfied = p2_input_NAMAC_satisfied./p2_nominal;
        NAMAC_predict_PFCL = output_prognosis_diagnosis(NAMAC_satisfied_action);
        NAMAC_margin_satisfied = NAMAC_margin(NAMAC_satisfied_action);
        
        % recommended actions based on the preference structure: more margin, more
        % preferrable

        [max_margin,NAMAC_index] = max(NAMAC_margin_satisfied);
        NAMAC_recommend = [time_trip_NAMAC_satisfied(NAMAC_index),...
            p2_input_fraction_satisfied(NAMAC_index),NAMAC_predict_PFCL(NAMAC_index)];
        sprintf('there are %d satisfied actioins found',num_NAMAC)
        sprintf('current diagnosed peak fuel centerline temperature is %f',FCL_diag(end))
        sprintf('NAMAC recommends to increase pump #2 by %f when T_{PFCL} reaches %f',...
            p2_input_fraction_satisfied(NAMAC_index),T_trip_NAMAC_satisfied(NAMAC_index))
        sprintf('the projected time for the trip temperature is %f',...
            time_trip_NAMAC_satisfied(NAMAC_index))
        sprintf('NAMAC predicts the maximum peak fuel centerline temperature in next 200 secs is %f',NAMAC_predict_PFCL(NAMAC_index))
        figure
%         levels = [-2,2,4,8];
        contour(T_mesh,p2_input_mesh,NAMAC_margin,'ShowText', 'on');
        ylabel('P#2 end speed (rad/s)')
        xlabel('Trip Temperature (C)')
    end
    
end
%%
%end
