opts = detectImportOptions("small.xlsx");
size(opts.VariableTypes)
[opts.VariableTypes{1:4}] = deal('string'); %,'string','string',
    %'string','string','string','string','string','string','string','string',
    %'string','string','string','string','string','string','string'];
T = readtable("small.xlsx",opts);


row = 1;

while(row <= size(T, 1))
    name = cell2mat(T{row,1})
    
    layer = str2num(cell2mat(T{row, 1}));
    T{row, 1} = "h"+T{row, 1};

    col = 2;
    ascii = double('a')
    if(layer < 2)
        while(col <= size(T, 2))
            if(T{row, col} == "-1")
                T{row, col} = "~"+string(char(ascii));
            elseif(T{row,col} == "1")
                T{row, col} = string(char(ascii));
            end
            col = col + 1;
            ascii = ascii + 1;
        end
    else
        while(col <= size(T, 2))
            if(T{row, col} == "-1")
                T{row, col} = "~h"+string(layer-1)+string(col-1);
            elseif(T{row,col} == "1")
                T{row,col} = "h"+string(layer-1)+string(col-1);
            end
            col = col+1;
            ascii = ascii + 1;
        end
    end
    row = row + 1;
end


% write rules to file
filename = "logicRules.csv";
writetable(T, filename);