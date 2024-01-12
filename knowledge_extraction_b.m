load('DT_Diagnosis.mat','net'); % NAMAC 
%load('simp.mat', 'net'); % simple NN


layerNum = 1
maxColumns = getMaxColumns(net);
T = array2table(zeros(1, maxColumns+1));

ruleSet = [];

% for each layer
while(layerNum <= net.numLayers)
    nodeNum = 1
    % for each hidden unit
    while(nodeNum <= net.layers{layerNum}.size)
        % Create a base rule
        weights = [];
        if(layerNum == 1)
            weights = net.IW{layerNum}(nodeNum,:);
        else
            weights = net.LW{layerNum, layerNum-1}(nodeNum,:);
        end
        signs = sign(weights);
        old_confidence = -1;
        new_confidence = sum(abs(signs.*weights))/sum(abs(signs));
        while(old_confidence ~= new_confidence)
            old_confidence = new_confidence;
            for i = 1:size(signs, 2)
                if (new_confidence >= 2* abs(weights(i)))
                    signs(i) = 0;
                end
            end
            if (sum(abs(signs)) == 0) 
                new_confidence = 0;
                break; 
            end
            new_confidence = sum(abs(signs.*weights))/sum(abs(signs));
        end
        ruleSet = writeRule(maxColumns, nodeNum, layerNum, new_confidence, signs, ruleSet);
        nodeNum = nodeNum + 1
    end
    layerNum = layerNum + 1
end

T = table;
T = [T array2table(ruleSet)];
T.Properties.VariableNames(1) = "output";
T.Properties.VariableNames(2) = "confidence";

% Remove duplicate rules 
T = unique(T);
% write rules to file
numRows = 1;
i = 1;
while(numRows < size(T, 1))
    filename = "confidenceRules" + i + ".csv";
    max = min(size(T, 1), numRows + 1000000);
    writetable(T(numRows:max,:), filename);
    numRows = numRows + 1000000;
    i = i + 1;
end


function [ruleSet] = writeRule(rowLength, outputIndex, layerNum, confidence, vect, rules)
    inputs = "";
    i = 1;
    vars = zeros(1, rowLength);
    while(i <= size(vect, 2))
        if(vect(i) == 1)
            vars(i) = 1;
            inputs = inputs + ", i" + i;
        elseif(vect(i) == -1)
                vars(i) = -1;
                inputs = inputs + ", ~i" + i;  
        else
            vars(i) = 0;
        end
        i = i + 1;
    end
    ruleSet = [rules; ["h^"+layerNum+"_"+outputIndex confidence vars]];
    disp("h^" + layerNum + "_" + outputIndex + " <- " + inputs);
end