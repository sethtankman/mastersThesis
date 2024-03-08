clear;

% WARNING: Does not work when there are more than 9 layers in the network

opts = detectImportOptions("rawRules1.csv");
[opts.VariableTypes{1:size(opts.VariableTypes, 2)}] = deal('string');
T = readtable("rawRules1.csv",opts);

fileID = fopen('convertedRules1.txt','w');

row = 2;
T = erase(regexprep(T{:,:}, '^0$', 'z'), "'");
newT = T;
while(row <= size(T, 1))
    name = cell2mat(T(row,1))
    
    layer = str2num(name(1));
    subset_T = T(strcmp(T(:,1), T(row, 1)), :);
    subset_T(:, 1) = repmat("h"+name+" :- ",size(subset_T,1),1);

    col = 2;
    ascii = double('a');
    while(col <= size(T, 2))
        subset_T(:,col) = strrep(subset_T(:,col),"-1","not "+string(char(ascii))+", ");
        subset_T(:,col) = strrep(subset_T(:,col),"1",string(char(ascii))+", ");
        col = col + 1;
        ascii = ascii + 1;
    end
    row = row + size(subset_T, 1);
    ruleArr = join(erase(subset_T(:, :), 'z'), '', 2);
    for i = 1:size(ruleArr, 1)
        ruleArr(i) = replaceBetween(ruleArr(i),strlength(ruleArr(i))-1, strlength(ruleArr(i)), '.\n');
    end
    finalString = join(ruleArr, '', 1);
    fprintf(fileID,finalString);
end

fclose(fileID);