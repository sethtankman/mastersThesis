% Truth Value CSV generator for confidence rules.
clear;

SZ = 3; % Set this to the number of inputs.
numCSVs = 1; % Set this to the number of CSV files to be read into one table
T = table;

for i = 1:numCSVs
    Tchunk = readtable("confidenceRules"+i+".csv");
    T = [T; Tchunk];
end

allInputs = zeros(2^SZ,SZ)-1;
for i = 2:2^SZ
    allInputs(i,:) = allInputs(i-1,:);
    for j = SZ:-1:1
        if(allInputs(i,j) == -1)
            allInputs(i,j) = 1;
            if(j<SZ)
                for k = j+1:SZ
                    allInputs(i,k) = -1;
                end
            end
            break;
        end
    end
end
disp(allInputs);

outputs = zeros(size(allInputs,1), 2);

% Generate truth values from confidence rules.
for j = 1:size(allInputs, 1)
    x = allInputs(j, :);
    i = 1;
    nextX = zeros(size(T{1, 3:end})) - 1;
    layer = '0';
    while i < size(T, 1)
        layerRules = T(strcmp(T{:,1}, T{i,1}), 2:end);
        layerRules = layerRules{:,1} * layerRules{:,2:end};
        head = char(T{i, 1});
        if(layer ~= head(3) && layer ~= '0')
            x = nextX;
            nextX = zeros(1,size(layerRules, 2)) - 1;
        end 
        layer = head(3);
        insertIndex = str2num(head(5:end));
        if(size(x, 2) < size(layerRules, 2))
            x(size(layerRules, 2)) = 0;
        end
        mult = x.*layerRules;
        if(sum(mult) > 0)
            nextX(insertIndex) = 1;
        end
        i = i + size(layerRules, 1);
    end
    outputs(j, 1) = nextX(1);
end

% generate truth values from network
load('DT_Diagnosis.mat', 'net'); % simple NN
for j = 1:size(allInputs, 1)
    x = allInputs(j, :);
    net.inputs{1}.size
    outputs(j,2) = net(x');
end