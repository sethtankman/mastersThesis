function rule2tex(conf,R,T)
% author: son tran
if ~isfield(conf,'vnames')
    inx = 1:size(R.r,1);
    conf.vnames = arrayfun(@(x) strcat('v_{',num2str(x),'}'),inx,'UniformOutput',false);
end

if ~isfield(conf,'lnames')
    lNum = size(T,1);
    if lNum==1, lNum = size(T.r,2); end
    inx = 1:size(lNum);
    conf.lnames = arrayfun(@(x) strcat('l_{',num2str(x),'}'),inx,'UniformOutput',false);
end

if ~isfield(conf,'use_bias') || conf.use_bias, conf.vnames{end+1} = ...
        'T'; end

if nargin<2
    fprintf('Error! No rules have been provided!!\n');
end
 
fid = fopen(strcat(conf.dir,conf.tex_f_name,'.tex'),'w');
if conf.full_doc
   fprintf(fid,'\\documentclass{article}\n');
   fprintf(fid,'\\usepackage{amsmath}\n');
   fprintf(fid,'\\begin{document}\n');
end

fprintf(fid,'\\begin{equation}\n');
fprintf(fid,'\\begin{aligned}\n');
% Extract normal rules
R.r
for i=1:size(R.r,2)
    str_rule = strcat('&',num2str(R.c(i)),': h_{',num2str(i),...  
                      '} \\leftrightarrow ');
   
    for k=1:size(R.r,1)
        if R.r(k,i)==0, continue; end
        if k>1,  str_rule = [str_rule,' \\wedge ']; end
        str_rule = [str_rule, ' '];
        if R.r(k,i)<0
            str_rule = [str_rule, ' \\neg '];
        end
        str_rule = [str_rule,' ', conf.vnames{k}];    
        
    end
    fprintf(fid, [str_rule,'\\\\']);
    fprintf(fid,'\n');
end 
if nargin>2 && ~isempty(T)
% Extract label  rules
if sum(sum(size(T.r)==size(T.c)))>0
    str_rule = strcat(num2str(R.c(i)),': h_{',num2str(i),...
                     '} \\leftrightarrow ');
    for k=1:size(R.r,1)
        if R.r(k,i)==0, continue; end
        if k>1,  str_rule = strcat(str_rule,' \\wedge '); end
        str_rule = strcat(str_rule, ' ');
        if R.r(k,i)<0
            str_rule = strcat(str_rule, '\\neg ');
        end
        str_rule = strcat(str_rule, conf.vnames{k});    
    end
    fprintf(fid, str_rule);
    fprintf(fid,'\n');
else % Layer-wise
    for k=1:size(T.r,1)-1
        for j=1:size(T.r,2)
            if T.c(k,j) ~=0
                str_rule = strcat(num2str(T.c(k,j)),': h_{', ...
                                  num2str(j),'\\leftrightarrow ');
                if T.r(k,j)<0, str_rule = strcat(str_rule,'\\neg '); end
                str_rule = strcat(str_rule,lnames{2});
                fprintf(fid,str_rule);
                fprintf(fid,'\n');
            end
        end
    end
end
end

fprintf(fid,'\\end{aligned}\n');
fprintf(fid,'\\end{equation}\n');

if conf.full_doc
   fprintf(fid,'\\end{document}\n');
end
fclose(fid);
end