clear;

% Displays the difference between the confidence network and the simple
% network.
%{
load("confidenceNetwork.mat", "myRBM");
load('simp.mat', 'net'); % simple NN
netinp = net.inputs{1}.size
tab = zeros(2^(net.inputs{1}.size), 2);
for i = 0:2^net.inputs{1}.size -1
    inputVec = [mod(floor(i/4),2);mod(floor(i/2),2);mod(i,2)];
    tab(i+1,1) = net([mod(i/4,2);mod(i/2,2);mod(i,2)]);
    tab(i+1,2) = myRBM([mod(i/4,2);mod(i/2,2);mod(i,2)]);
end
myRBM.IW{1,1}
myRBM.LW{2,1}
net.IW{1,1}
net.LW{2,1}
disp(tab)
%}

% Validates that Normalizing inputs produces the same results with NAMAC V2
load('DT_Diagnosis.mat','net'); % NAMAC 

% Get input table from data
tab = readtable("histories_short_print_400.csv");
time=tab.time;
t_acc=0;%time at which the accident is injected
t_recmd=5;%time unitil which NAMAC collects sensor data
[val_trans,pos_trans] = min(abs(time-t_acc));
[val_diag,pos_diag] = min(abs(time-t_recmd));
TL14=tab.TL14s1;
TL9=tab.TL9s1;
TL8=tab.TL8s1;
HP_LP_diag = TL8(pos_trans:pos_diag);  % High-Pressure Lower Plenum
LP_LP_diag = TL9(pos_trans:pos_diag); % Low-Pressure Lower Plenum
UP_diag = TL14(pos_trans:pos_diag); % Higher Plenum
input_diag = [HP_LP_diag,LP_LP_diag,UP_diag]';
expected_output = net(input_diag);
vecMin = min(input_diag, [], 2);
vecMax = max(input_diag, [], 2);
normalized = getNorm(input_diag, vecMin, vecMax);
actual_output = net(normalized);
diff = actual_output - expected_output;
% Expected output is the predicted Fuel Centerline Temperature. 

function [norm] = getNorm(val, vecMin, vecMax)
    rhs = repmat(vecMax - vecMin, 1, size(val, 2))
    norm = ((val - vecMin)./repmat(vecMax - vecMin, 1, size(val, 2)));
end