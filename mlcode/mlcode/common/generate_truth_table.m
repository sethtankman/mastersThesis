function ttable = generate_truth_table(prop_sentence,names)
%% get all possible variables
varNum = size(names,2);

x = [0,1];
for i=varNum-1
    x = combvec(x,[0 1]);
end

%% convert sentence to matlab expression
mat_expr = prop_sentence;
for i = 1:varNum
    mat_expr = strrep(mat_expr,names{i},strcat('x(',num2str(i),',:)'));
end
% run 
ttable = eval(mat_expr);
ttable = [x;ttable]';
end