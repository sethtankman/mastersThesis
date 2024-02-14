clear;

%% Manual Settings
%load('DT_Diagnosis.mat','net'); % NAMAC 
load('simp.mat', 'net'); % simple NN
A_min = 0.1;
%%

layerNum = 1
nodeNum = 1
maxColumns = getMaxColumns(net);
T = array2table(zeros(1, maxColumns+1));
T.Properties.VariableNames(1) = "output";

while(layerNum <= net.numLayers) %net.numLayers
    while(nodeNum <= net.layers{layerNum}.size) % net.layers{layerNum}.size
        % Create Basic Neural Structure
        myBNS = network; % later use network(numInputs,numLayers,biasConnect,inputConnect,layerConnect,outputConnect)
        if(layerNum == 1)
            myBNS.numInputs = net.numInputs; % This actually sets the number of vectors of inputs
            myBNS.inputs{1}.size = net.inputs{1}.size; % This is the number of inputs in the vector
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
        %netBias = net.b{layerNum}(nodeNum, 1)
        %netWeight = net.IW % Input weights
        if(layerNum == 1)
            myBNS = setwb(myBNS, [net.b{layerNum}(nodeNum,1),net.IW{layerNum}(nodeNum,:)]);
        else
            myBNS = setwb(myBNS, [net.b{layerNum}(nodeNum,1),net.LW{layerNum, layerNum-1}(nodeNum,:)]);
        end

        %% Knowledge Extraction for Regular Networks
        % Perform Transformation Algorithm
        if size(myBNS.IW{1}, 2) > 5
            bnsW = myBNS.IW{1,1};
        end
        
        [negVec, w] = positiveForm(myBNS.IW{1}); % Obtain positive form of weights and negation vector
        [w, I] = sort(w, 'descend'); % Sort weights in descending order
        negVec = negVec(I); % Sort negation vector the same way.
    
        % Find Infimum and Supremum
        ruleSet = [];
        [lattice, mask] = getLattice(negVec, layerNum == 1, A_min);
        lattice(:,I+1) = lattice(:,2:end); % Sort lattice back to BNS ordering
        mask(:,I+1) = mask(:,2:end);
        supremum = lattice(1, :);
        infimum = lattice(size(lattice, 1),:);

        % Query Infimum
        inputVec = infimum(2:end);
        infResult = myBNS(transpose(inputVec));
        if(infResult >= 0) % TODO: Should be > 0
            disp("h^" + layerNum + "_" + nodeNum + " <-");
            T2 = table;
            T2.outPut = [layerNum + "_" + nodeNum];
            T2 = [T2 array2table(zeros(1, maxColumns))];
            T2.Properties.VariableNames = T.Properties.VariableNames;
            T = [T;T2];
            nodeNum = nodeNum + 1;
            continue;
        end

        % Query Supremum
        inputVec = supremum(2:end);
        supResult = myBNS(transpose(inputVec));
        if(supResult < 0) % TODO: Should be <= 0
            nodeNum = nodeNum + 1;
            continue;
        end

        % Perform Linear Search on the lattice.
        infIndex = size(lattice, 1) - 1;
        supIndex = 2;
        while infIndex >= size(lattice, 1)/2 || supIndex <= size(lattice, 1)/2
            infimum = lattice(infIndex,:);
            inputVec = infimum(2:end);
            infResult = myBNS(transpose(inputVec));
            if(infResult > 0)
                ruleSet = writeRule(maxColumns, inputVec, ruleSet);
            end
            supremum = lattice(supIndex, :);
            inputVec = supremum(2:end);
            supResult = myBNS(transpose(inputVec));
            if(supResult > 0)
                ruleSet = writeRule(maxColumns, inputVec, ruleSet);
            end
            infIndex = infIndex - 1;
            supIndex = supIndex + 1;
        end
        
        if(size(ruleSet, 1) > 0)
            outputNodes = repmat(layerNum + "_" + nodeNum, size(ruleSet, 1), 1);
            T2 = table;
            T2.outPut = outputNodes;
            T2 = [T2 array2table(ruleSet)];
            T2.Properties.VariableNames = T.Properties.VariableNames;
            T = [T;T2];
        end
        nodeNum = nodeNum + 1
    end
    layerNum = layerNum + 1
    nodeNum = 1
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



function [ruleSet] = writeRule(rowLength, vect, rules)
    %inputs = "";
    i = 1;
    vars = zeros(1, rowLength);
    while(i <= size(vect, 2))
        if(vect(i) == 1)
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

% Calculates the positive form of a set of weights, returns the negation
% vector showing which values were flipped and the resulting weight vector. 
function [negVec, w] = positiveForm(weights)
    negVec = ones(1,size(weights, 2));
    for index = 1:size(weights,2)
        if weights(index) < 0
            negVec(index) = -1;
            weights(index) = -1 * weights(index);
        end
    end
    w = weights;
end

% Given a max vector (negVec), obtains the lattice of 
% input vectors from greatest to least. Also returns a mask matrix which 
% shows which values to mask when adding rules. (1 meaning show the rule, 
% 0 meaning mask it)
function [lattice, mask] = getLattice(negVec, isInputLayer, A_min)
    if (~isInputLayer)
        negVec(negVec == -1) = A_min; % Set all -1 values to 0 since the min of all inputs is 0, not -1.
    end
    vecSize = size(negVec, 2);
    lattice = ones(2^(vecSize), vecSize+1); % Adding additional element to represent row number
    mask = lattice;
    lattice(1, :) = [1 negVec];
    i=2; % i: the number of the lattice we are computing
    markers = [vecSize];
    while(size(markers, 2) < vecSize)
        % size(markers, 2) + 1 is the lattice row number
        lattice(i, :) = [size(markers, 2)+1 getLatticeEntry(markers, negVec, isInputLayer, A_min)];
        mask(i,:) = [size(markers, 2)+1 getLatticeEntry(markers, ones(1, vecSize), isInputLayer, A_min)];
        j = 1; % index of markers
        k = 2; % next index of markers
        while(k <= size(markers, 2) && markers(j)-1 == markers(k))
            markers(j) = vecSize - j + 1;
            j = j + 1;
            k = k + 1;
        end
        markers(j) = markers(j) - 1;
        if(markers(j) < 1)
            l = 0;
            while(l < size(markers, 2))
                markers(l+1) = vecSize - l;
                l = l + 1;
            end
            markers = [markers (vecSize - l)];
        end
        i = i + 1;
    end
    lattice(i,:) = [vecSize+1 getLatticeEntry(markers, negVec, isInputLayer, A_min)];
    mask(i, :) = [vecSize+1 getLatticeEntry(markers, ones(1, vecSize), isInputLayer, A_min)];
end

% Calculates the specific vector (entry) given the markers of which 
% values to change and the original negation vector negVec
function [entry] = getLatticeEntry(markers, negVec, isInputLayer, A_min)
    i = 1;
    entry = negVec;
    if(isInputLayer)
        while(i <= size(markers, 2))
            entry(markers(i)) = -1 * entry(markers(i)); % toggle +1 or -1
            i = i + 1;
        end
    else
        while(i <= size(markers, 2))
            entry(markers(i)) = 1 - entry(markers(i)) + A_min; % toggle A_min or 1.
            i = i + 1;
        end
    end
end

function [norm] = getNorm(val, vecMin, vecMax)
    norm = ((val - vecMin)/(vecMax - vecMin));
end