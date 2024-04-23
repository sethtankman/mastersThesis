%% Manual Settings
clear; % Comment out when timing.

load('DT_Diagnosis.mat','net'); % NAMAC 
%load('simp.mat', 'net'); % simple NN
%load('mixed.mat', 'net');

inputVecs = getInitialInputs(3, net.inputs{1}.size);
%%

layerNum = 1
nodeNum = 1
maxColumns = net.inputs{1}.size;
T = array2table(zeros(1, maxColumns+1));
T.Properties.VariableNames(1) = "output";
layerInputs = inputVecs;
inputMin = net.inputs{1}.processSettings{1}.xmin;
inputMax = net.inputs{1}.processSettings{1}.xmax;
outputMin = net.outputs{net.numLayers}.processSettings{1}.xmin; 
outputMax = net.outputs{net.numLayers}.processSettings{1}.xmax;

while(layerNum <= net.numLayers) %net.numLayers
    nextLayerInputs = ones(size(inputVecs, 1), net.layers{layerNum}.size);
    while(nodeNum <= net.layers{layerNum}.size) % net.layers{layerNum}.size
        % Create Basic Neural Structure
        myBNS = network; % TODO: later use network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect)
        if(layerNum == 1)
            myBNS.numInputs = net.numInputs; % This actually sets the number of vectors of inputs
            myBNS.inputs{1}.processFcns = {'mapminmax'};
            myBNS.inputs{1}.size = net.inputs{1}.size; % This is the number of inputs in the vector
            myBNS.inputs{1}.exampleInput = [inputMin, inputMax];
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
        % Denormalize outputs
        %if(layerNum == net.numLayers)
            %myBNS.outputs{1}.processFcns = {'mapminmax'};
            %myBNS.outputs{1}.exampleOutput = [outputMin, outputMax];
        %end

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
                ruleSet = [ruleSet;inputVecs(inputNum, :)];
                %ruleSet = writeRule(maxColumns, inputVecs(inputNum, :), ruleSet);
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
    denorm = inputVec.*(max - min)'+min';
end

% function [ruleSet] = writeRule(rowLength, vect, rules)
%     %inputs = "";
%     i = 1;
%     vars = zeros(1, rowLength);
%     while(i <= size(vect, 2))
%         if(vect(i) > 0)
%             vars(i) = 1;
%             %inputs = inputs + ", i" + i;
%         else
%             vars(i) = -1;
%             %inputs = inputs + ", ~i" + i;  
%         end
%         i = i + 1;
%     end
%     ruleSet = [rules; vect];
%     %disp("h^" + layerNum + "_" + outputIndex + " <- " + inputs);
% end

% Given a quantization integer > 1 quant and an input vector size ivs, 
% obtains the initial possible input vectors for the network.  
function [inputVecs] = getInitialInputs(quant, ivs)
    inputVecs = ones(quant^(ivs), ivs);
    i=2;
    markers = [ivs];
    while(size(markers, 2) <= ivs)
        inputVecs(i, :) = getLatticeEntry(markers, inputVecs(1, :), quant);
        j = 1; % index of markers
        k = 2; % next index of markers
        markers(j) = subtractQuantum(markers(j), quant);
        while(k <= size(markers, 2) && markers(j) == ceil(markers(k)))
            markers(j) = ivs - j + 1;
            markers(k) = subtractQuantum(markers(k), quant);
            j = j + 1;
            k = k + 1;
        end
        if(markers(j) <= 0) % Accounts for roundoff error, but limits to 1 million quantizations.
            l = 0;
            while(l < size(markers, 2))
                markers(l+1) = ivs - l;
                l = l + 1;
            end
            markers = [markers (ivs - l)];
        end
        i = i + 1;
    end
end

% Cleanly subtracts a quantum in a way that accounts for roundoff error
function [difference] = subtractQuantum(minuend, quant)
    difference = minuend - (1/(quant-1));
    if (abs(difference - round(difference)) < 0.000001)
        difference = round(difference);
    end
end

% Calculates the specific vector (entry) given the markers of which 
% values to change and the original negation vector negVec (Always an array
% of ones in this case)
function [entry] = getLatticeEntry(markers, negVec, quant)
    i = 1;
    entry = negVec;
    while(i <= size(markers, 2))
        stepSize = markers(i) - floor(markers(i));
        if(stepSize < 0.000001)
            stepSize = 1;
        end
        stepSize = 2 * ((1-stepSize)+1/(quant -1));
        entry(ceil(markers(i))) = entry(ceil(markers(i))) - stepSize;
        if(abs(entry(ceil(markers(i))) - round(entry(ceil(markers(i))))) < 0.000001)
            entry(ceil(markers(i))) = round(entry(ceil(markers(i))));
        end
        i = i + 1;
    end
end

function [norm] = getNorm(val, vecMin, vecMax)
    norm = ((val - vecMin)/(vecMax - vecMin));
end