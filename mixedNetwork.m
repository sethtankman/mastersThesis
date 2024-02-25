net = network(1, 2,[1;1],[1;0],[0,0;1,0], [0,1]);
net.inputs{1}.size = 3;
net.layers{1}.size = 3;
net.layers{2}.size = 1;
net = setwb(net, [0;0;0;0.9;0.8;0.5;0.7;-0.6;0.5;-0.4;-2;-0.6;0;0.6;0.4;-1]); 
% [b1_1; b1_2; b1_3; w1_1,1; w1_1,2; w1_1,3; w1_2,1; etc.]
net.IW{1,1}
net.LW{2,1}
net.b{1}
net.b{2}
%view(net)
save("mixed.mat", "net")

%% Expected Rules:
% h1 <- a,b
% h1 <- a,~c
% h1 <- b,~c
% h2 <- ~c
% h3 <- a,b
% h3 <- a,~c
% h3 <- b,~c
% o <- h2,~h3
% o <- h1,~h3

%% Expected Rules for Knowledge Extraction e:
% h1 <- a,b,c
% h1 <- a,b,~c
% h1 <- a,~b,~c
% h1 <- ~a,b,~c
% h2 <- a,b,~c
% h2 <- a,~b,~c
% h2 <- ~a,b,~c
% h2 <- ~a,~b,~c
% h3 <- a,b,c
% h3 <- a,b,~c
% h3 <- a,~b,~c
% h3 <- ~a,b,~c
% o <- a,b,~c
% o <- a,~b,c
% o <- a,~b,~c
% o <- ~a,~b,~c