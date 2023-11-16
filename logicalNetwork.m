T = readtable("confidenceRules1.csv");
% load('DT_Diagnosis.mat','net'); % NAMAC 
load('simp.mat', 'net'); % simple example
trainData = 

% TODO: Add user selection of tables here.

% Construct new neural network based on rules.
myRBM = network;
myRBM.numInputs = net.numInputs;
myRBM.inputs{1}.size = net.inputs{1}.size;
myRBM.numLayers = net.numLayers;
net.numLayers
for layer = 1:net.numLayers
    myRBM.layers{layer}.size = net.layers{layer}.size;
    myRBM.layers{layer}.transferFcn =  net.layers{layer}.transferFcn;
end
myRBM.biasConnect = ones(net.numLayers, 1); % all layers have a bias.
myRBM.inputConnect = zeros(net.numLayers, 1);
myRBM.inputConnect(1) = 1; % connect input to the first hidden layer.
myRBM.layerConnect = net.layerConnect;
myRBM.outputConnect = net.outputConnect;

% weight = net.LW

% Initializations
rows = size(T, 1);
prevLayer = 0;
prevNode = 0;
weights = num2cell(zeros(net.numLayers));
nodeTotal = [];
weightMatrix = zeros(net.layers{1}.size,net.inputs{1}.size);
pat = "_" + digitsPattern; % Matlab's form of REGEX

% For each row of the table
for row = 1:rows
    rule = T(row,:);
    layer = str2num(cell2mat(extract(rule{1, 1}, 3)));
    if(layer ~= prevLayer)
        if(prevLayer ~= 0)
            % Set all weights for each layer.
            weights{prevLayer+1, prevLayer} = weightMatrix
            weightMatrix = zeros(net.layers{layer}.size,net.layers{layer-1}.size);
            prevNode = 0;
        end
        prevLayer = layer;
    end
    node = extract(rule{1,1}, pat);
    node = str2num(cell2mat(extract(node, digitsPattern)));
    if(prevNode ~= node)
        if(prevNode ~= 0)
            % Set the value of the connection weights
            weightMatrix(prevNode, :) = nodeTotal(1,1:size(weightMatrix,2));
        end
        nodeTotal = zeros(1, net.layers{layer}.size);
    end
    myArr = table2array(T(row, 2:net.layers{layer}.size+2));
    nodeTotal = nodeTotal + table2array(T(row, 2:net.layers{layer}.size+2))
    prevNode = node;
% end for
end

% Tab = table to reduce
% maxRec = max number of recursions.
function [ruleSet] = Reduce(tab, maxRec)
    disp("Reduce");
    
    i=1;
    numRec = 0;
    % Check if rules can be subsumed
    while(i < size(tab, 1))
        j = i+1;
        while(tab{i,1} == tab{j,1} && j <= size(tab,1))
            combined = sum(tab{[i,j],:});
            if(sum(combined == 0) == 1) % If one element of the sum of two matrices is 0, 
                if(numRec < maxRec) % Recursive calls skip over subsumations, so after enough skips the number of rules will start increasing.
                    secondarySet = ReduceRecursive(i, j+1, tab, numRec, maxRec)
                    numRec = numRec + 1;
                end
                combined = combined/2;
                tab(i, :) = array2table(combined);
                tab(j, :) = [];
                break;
            end
            j = j + 1;
        end
        i = i + 1;
    end
    ruleSet = tab;
end

function [ruleSet] = ReduceRecursive(i, j, tab, numRec, maxRec)
    foundBranch = false; 
    while(i < size(tab,1))
        while(j <= size(tab, 1) && tab{i,1} == tab{j,1})
            combined = sum(tab{[i,j],:});
            if(sum(combined == 0) == 1)
                if(numRec < maxRec) % Recursive calls skip over subsumations, so after enough skips the number of rules will start increasing.
                    secondarySet = ReduceRecursive(i, j+1, tab, numRec, maxRec)
                    numRec = numRec + 1;
                end
                combined = combined/2;
                tab(i, :) = array2table(combined);
                tab(j, :) = [];
                foundBranch = true;
                break;
            end
            j = j + 1;
        end
        i = i + 1;
        j = i + 1;
    end
    ruleSet = [];
    if(foundBranch)
        ruleSet = tab;
    end
end