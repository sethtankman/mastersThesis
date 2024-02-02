net = network(1, 2,[1;1],[1;0],[0,0;1,0], [0,1]);
net.inputs{1}.size = 3;
net.layers{1}.size = 3;
net.layers{2}.size = 1;
net = setwb(net, [-1.5;-1.5;-1.5;0.9;0.8;0.5;0.7;0.6;0.5;0.4;2;0.6;-1.5;0.6;0.4;1]); 
% [b1_1; b1_2; b1_3; w1_1,1; w1_1,2; w1_1,3; w1_2,1; etc.]
net.IW{1,1}
net.LW{2,1}
net.b{1}
net.b{2}
view(net)
save("simp.mat", "net")