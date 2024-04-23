clear;

% Set this to appropriate number before running
numFiles = 1;
quant = 3;


stepSize = 2/(quant-1);

T = table;
for i = 1:numFiles
    filename = "rawRules"+i+".csv";
    T = [T; readtable(filename)];
end

rules = [];
i = 1;
while (i <= size(T,1))
    head = T{i,1};
    layerRules = T(strcmp(T{:,1}, T{i,1}), 2:end);
    j = 1;
    while (j <= size(layerRules,1))
        point = layerRules(j,:);
        k = 1; 
        while (k <= size(point, 2))
            max = point{1,k};
            min = point{1,k};
            pluspoint = point;
            pluspoint{1,k} = pluspoint{1,k} + stepSize;
            minuspoint = point;
            minuspoint{1,k} = minuspoint{1,k} - stepSize;
            while (ismember(pluspoint, layerRules))
                max = pluspoint{1,k};
                pluspoint{1,k} = pluspoint{1,k} + stepSize;
            end
            while (ismember(minuspoint, layerRules))
                min = minuspoint{1,k};
                minuspoint{1,k} = minuspoint{1,k} - stepSize;
            end
            if(max ~= min) % This operates under the assumption that all points will be connected to a line.
                newRule = strip(cellstr(num2str(point{:,:}'))');
                newRule{1,k} = append(num2str(min),':',num2str(max));
                rules = [rules; newRule];
            end
            k = k + 1;
        end
        j = j + 1;
    end
    rules = unique(string(rules),'rows');
    i = i + size(layerRules, 1) ;
end