clear;

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