%% Manual Settings
clear; % Comment out when timing.

load('DT_Diagnosis.mat','net'); % NAMAC 
%load('simp.mat', 'net'); % simple NN
%load('mixed.mat', 'net');

inputVecs = getInitialInputs(2, net.inputs{1}.size); 
inputMin = [380,380,480];
inputMax = [389,389,580];
%%

layerNum = 1
nodeNum = 1
maxColumns = getMaxColumns(net);
T = array2table(zeros(1, maxColumns+1));
T.Properties.VariableNames(1) = "output";
layerInputs = inputVecs;

while(layerNum <= net.numLayers) %net.numLayers
    nextLayerInputs = ones(size(inputVecs, 1), net.layers{layerNum}.size);
    while(nodeNum <= net.layers{layerNum}.size) % net.layers{layerNum}.size
        % Create Basic Neural Structure
        myBNS = network; % later use network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect)
        if(layerNum == 1)
            myBNS.numInputs = net.numInputs; % This actually sets the number of vectors of inputs
            myBNS.inputs{1}.processFcns = {'mapminmax'};
            myBNS.inputs{1}.size = net.inputs{1}.size; % This is the number of inputs in the vector
            myBNS.inputs{1}.exampleInput = [net.inputs{1}.processSettings{1}.xmin, net.inputs{1}.processSettings{1}.xmax];
        else
            myBNS.numInputs = 1;
            myBNS.inputs{1}.size = net.layers{layerNum-1}.size;
        end
        myBNS.numLayers = 1; % Single-layer NN
        myBNS.layers{1}.size = 1; % One node
        myBNS.biasConnect = 1; % The layer has a bias.
        myBNS.inputConnect = ones(1,1); % connect all inputs to hidden layer.
        myBNS.layerConnect = false; % There is no weight coming from layer 1 to layer 1.
        myBNS.outputConnect = true; % there is an output layer.
        myBNS.layers{1}.transferFcn = net.layers{layerNum}.transferFcn; % Set the same transfer function as with the original network
        if(layerNum == net.numLayers)
            myBNS.outputs{1}.processFcns = {'mapminmax'};
            myBNS.outputs{1}.exampleOutput = [net.outputs{net.numLayers}.processSettings{1}.xmin, net.outputs{net.numLayers}.processSettings{1}.xmax];
        end
        %netBias = net.b{layerNum}(nodeNum, 1)
        %netWeight = net.IW % Input weights
        if(layerNum == 1)
            myBNS = setwb(myBNS, [net.b{layerNum}(nodeNum,1),net.IW{layerNum}(nodeNum,:)]);
        else
            myBNS = setwb(myBNS, [net.b{layerNum}(nodeNum,1),net.LW{layerNum, layerNum-1}(nodeNum,:)]);
        end

        %% Knowledge Extraction for Discrete Regular Networks

        inputs = inputVecs;
        if(layerNum ~= 1)
            inputs = layerInputs;
        end

        % Query all inputs.
        inputNum = 1;
        ruleSet = [];
        while inputNum <= size(inputs, 1)
            inputVec = inputs(inputNum, :);
            if(layerNum == 1)
                inputVec = denormalize(inputVec, inputMin, inputMax);
                %netOutput = net(transpose(inputVec))
            end
            actValue = myBNS(transpose(inputVec));
            if(actValue > 0)
                ruleSet = writeRule(maxColumns, inputVecs(inputNum, :), ruleSet);
            end
            nextLayerInputs(inputNum, nodeNum) = actValue;
            inputNum = inputNum + 1;
        end

        if(size(ruleSet, 1) > 0)
            outputNodes = repmat(layerNum + "_" + nodeNum, size(ruleSet, 1), 1);
            T2 = table;
            T2.outPut = outputNodes;
            T2 = [T2 array2table(ruleSet)];
            T2.Properties.VariableNames = T.Properties.VariableNames;
            T = [T;T2];
        end
        nodeNum = nodeNum + 1;
    end
    layerInputs = nextLayerInputs;
    layerNum = layerNum + 1;
    nodeNum = 1;
end
denormalize(nextLayerInputs, 600, 700)

% Remove duplicate rules 
T = unique(T, 'stable');

% write rules to file
numRows = 1;
i = 1;
while(numRows < size(T, 1))
    filename = "rawRules" + i + ".csv";
    max = min(size(T, 1), numRows + 1000000);
    writetable(T(numRows:max,:), filename);
    numRows = numRows + 1000000;
    i = i + 1;
end

% Done

% Given an input vector normalized between -1 and 1, denormalizes input
function [denorm] = denormalize(inputVec, min, max)
    inputVec = (inputVec + 1)/ 2;
    denorm = inputVec.*(max - min)+min;
end

function [ruleSet] = writeRule(rowLength, vect, rules)
    %inputs = "";
    i = 1;
    vars = zeros(1, rowLength);
    while(i <= size(vect, 2))
        if(vect(i) > 0)
            vars(i) = 1;
            %inputs = inputs + ", i" + i;
        else
            vars(i) = -1;
            %inputs = inputs + ", ~i" + i;  
        end
        i = i + 1;
    end
    ruleSet = [rules; vars];
    %disp("h^" + layerNum + "_" + outputIndex + " <- " + inputs);
end

% Given a quantization integer > 1 quant and an input vector size ivs, 
% obtains the initial possible input vectors for the network.  
function [inputVecs] = getInitialInputs(quant, ivs)
    inputVecs = ones(quant^(ivs), ivs);
    i=2;
    markers = [ivs];
    while(size(markers, 2) < ivs)
        inputVecs(i, :) = getLatticeEntry(markers, inputVecs(1, :));
        j = 1; % index of markers
        k = 2; % next index of markers
        while(k <= size(markers, 2) && markers(j)-1 == markers(k))
            markers(j) = ivs - j + 1;
            j = j + 1;
            k = k + 1;
        end
        markers(j) = markers(j) - 1;
        if(markers(j) < 1)
            l = 0;
            while(l < size(markers, 2))
                markers(l+1) = ivs - l;
                l = l + 1;
            end
            markers = [markers (ivs - l)];
        end
        i = i + 1;
    end
    inputVecs(i,:) = getLatticeEntry(markers, inputVecs(1, :));
end

% Calculates the specific vector (entry) given the markers of which 
% values to change and the original negation vector negVec (Always an array
% of ones in this case)
function [entry] = getLatticeEntry(markers, negVec)
    i = 1;
    entry = negVec;
    while(i <= size(markers, 2))
        entry(markers(i)) = -1 * entry(markers(i)); % toggle +1 or -1
        i = i + 1;
    end
end

function [norm] = getNorm(val, vecMin, vecMax)
    norm = ((val - vecMin)/(vecMax - vecMin));
end