load('DT_Diagnosis.mat','net');
% lgraph = layerGraph(net) % requires seriesNetwork, DAGNetwork, or
% dlnetwork object.  net is a 'network' object.
% plot(lgraph) 

% Create Basic Neural Structure
myBNS = network % later use network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect)
% myBNS.numInputs = net.inputs{1}.size; % Shows all three input boxes
myBNS.numInputs = 1; % This actually sets the number of vectors of inputs
myBNS.inputs{1}.size = net.inputs{1}.size; % This is the number of inputs in the vector
myBNS.numLayers = 1; % Single-layer NN
myBNS.layers{1}.size = 1; % One node
myBNS.biasConnect = [1]; % The layer does have a bias.
myBNS.inputConnect = ones(1,1); % connect all inputs to hidden layer.
myBNS.layerConnect = false; % There is no weight coming from layer 1 to layer 1.
myBNS.outputConnect = true; % there is an output layer.
myBNS.layers{1}.transferFcn = net.layers{1}.transferFcn; % Set the same transfer function as with the original network
% myBNS.biases{1} = net.biases{1};
% myBNS.biases{1}.size = net.biases{1}.size;
myBNS = setwb(myBNS, [net.b{1}(1,1),net.IW{1}(1,:)]); 

% View Results
view(myBNS);
%view(net)
disp("Bias")
% myDub = net.b{1}(1,1); % network -> biases -> layer1 -> index(1,1)
disp(myBNS.b);
disp("Weights");
disp(myBNS.IW);
% celldisp(net.inputs);
% celldisp(net.b);
%celldisp(myBNS.b)

[negVec, w] = positiveForm(myBNS.IW{1}); % Obtain positive form of weights and negation vector
[w, I] = sort(w, 'descend'); % Sort weights in descending order
negVec = negVec(I); % Sort negation vector the same way.
disp(negVec)
disp(w)




function [negVec, w] = positiveForm(weights)
    negVec = [1,1,1];
    for index = 1:3
        if weights(index) < 0
            negVec(index) = -1;
            weights(index) = -1 * weights(index);
        end
    end
    w = weights;
end
    