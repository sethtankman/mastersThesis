net = network(1, 2,[1;1],[1;0],[0,0;1,0], [0,1]);
net.inputs{1}.size = 2;
net.layers{1}.size = 2;
net.layers{2}.size = 1;
net = setwb(net, [1.5;1.5;1.5;1;1;1;1;1;1]);
net.IW{1,1}
net.b{1}
net.b{2}
view(net)
save("simp.mat", "net")