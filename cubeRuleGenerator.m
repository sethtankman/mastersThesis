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

allRules = repmat("A",1,4);
i = 1;
while (i <= size(T,1))
    rules = [];
    head = T{i,1}
    layerRules = T(strcmp(T{:,1}, T{i,1}), 2:end);
    j=1;
    while(j < size(layerRules,1))
        xyz = layerRules(j,:);
        xyz = [xyz;xyz;xyz;xyz;xyz;xyz;xyz;xyz];
        xyz{5:8,1} = xyz{5:8,1}+stepSize;
        xyz{[3,4,7,8],2} = xyz{[3,4,7,8],2} + stepSize;
        xyz{[2,4,6,8],3} = xyz{[2,4,6,8],3} + stepSize;
        out = ismember(xyz,layerRules);
        if(ismember(xyz,layerRules))
            newRule = [xyz{1,1}+":"+(xyz{1,1}+stepSize),...
                +xyz{1,2}+":"+(xyz{1,2}+stepSize),...
                +xyz{1,3}+":"+(xyz{1,3}+stepSize)];
            rules = [rules; newRule];
        end
        j = j+1;
    end
    heads = repmat(head,size(rules,1),1);
    rules = [heads,rules];
    if(size(rules,1) >0)
        allRules = [allRules;rules];
    end
    i = i + size(layerRules, 1);
end