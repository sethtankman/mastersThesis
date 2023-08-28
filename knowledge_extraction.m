load('DT_Diagnosis.mat','net');
% lgraph = layerGraph(net) % requires seriesNetwork, DAGNetwork, or
% dlnetwork object.  net is a 'network' object.
% plot(lgraph) 
%view(net) % The view function shows layers, not nodes.
myBNS = network % later use network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect)
myBNS.numInputs = net.inputs{1}.size;
myBNS.numLayers = 1; 
myBNS.biasConnect = [1]; % The layer does have a bias.
myBNS.inputConnect = zeros(1,net.inputs{1}.size) + 1; % connect all inputs to hidden layer.
myBNS.layerConnect = false; % There is no weight coming from layer 1 to layer 1.
myBNS.outputConnect = true; % there is an output layer.
myBNS.layers{1}.transferFcn = 'tansig'
myBNS = setwb(myBNS, rand(10,1));
view(myBNS);
% celldisp(net.inputs);
% celldisp(net.b);
%celldisp(myBNS.b)
% disp(net.b{1,1}(1))
celldisp(myBNS.IW)
myBNS.IW{1,1}