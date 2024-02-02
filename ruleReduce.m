clear;

% Set this to appropriate number before running
numFiles = 1;
T = table;
for i = 1:numFiles
    filename = "rawRules"+i+".csv";
    T = [T; readtable(filename)];
end
%T = readtable("small.xlsx");
newTable = T;

startIndex = 2;
node = cell2mat(T{2,1});
startRowCt = 1;
removedCt = 0;
row = 2;
while row <= size(T, 1)
   curNode = cell2mat(T{row,1});
   curRow = T{row,2:end};
   nodeRules = T(strcmp(T.output, curNode), :);
   sumEqZero = sum(nodeRules(:,2:end) == 0, 2);
   cmpRules = sumEqZero == sumEqZero(1,1);
   cmpRules = cmpRules{:,:};
   cmpRules = nodeRules{cmpRules, 2:end};
   reduceables = sumEqZero ~= sumEqZero(1,1);
   reduceables = reduceables{:,:};
   reduceables = nodeRules(reduceables, :);
   startRowCt = size(cmpRules,1);
   row = row + size(cmpRules, 1);
   for reduceable = 1:size(reduceables, 1)
       reduceRow = reduceables{reduceable,2:end};
       combinedRules = abs(cmpRules) + repmat(abs(reduceRow),startRowCt,1);
       %columnVector = sum(combinedRules == 1, 2);
       %containsDiffOfOne = sum(sum(combinedRules == 1, 2) == 1); % substituting above line
       diffOfOne = sum(sum(combinedRules == 1, 2) == 1) >= 1; % substituting above line
       %aveg = sum(combinedRules, 2)*0.5;
       %     allSameButOne = sum(combinedRules, 2)*0.5 == sum(abs(curRow))+0.5; % substitution
       containsASBO = sum((sum(combinedRules, 2)*0.5 == sum(abs(curRow))+0.5) == 1) >= 1; % substitution
       if(diffOfOne && containsASBO)
           removedCt = removedCt + 1;
           disp("Removed row "+row+", totaling "+removedCt+ " rows!")
           newTable{row,2:end} = zeros(1, size(newTable, 2)-1); % Zero out the row, remove duplicates later.
           newTable{row,1} = {'0'};
       end
       row = row + 1;
   end
end

newTable = unique(newTable, 'stable');

% write rules to file
numRows = 1;
i = 1;
while(numRows < size(newTable, 1))
    ofilename = "reducedRules" + i + ".csv";
    max = min(size(newTable, 1), numRows + 1000000);
    writetable(newTable(numRows:max,:), ofilename);
    numRows = numRows + 1000000;
    i = i + 1;
end