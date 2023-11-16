function discrete_rule2tex(conf,R)
% Write rules to latex
rules = softmax2discrete_rule(R.r,conf.d_ranges);

if ~isfield(conf,'vnames')
    inx = 1:size(R.r,1);
    conf.vnames = arrayfun(@(x) strcat('v_{',num2str(x),'}'),inx,'UniformOutput',false);
end
 

fid = fopen(strcat(conf.dir,conf.tex_f_name,'.tex'),'w');
if conf.full_doc % the tex contain document format 
   fprintf(fid,'\\documentclass[landscape,a3paper]{article}\n');
   fprintf(fid,'\\usepackage[lmargin=1cm, rmargin=1cm,tmargin=1.5cm,bmargin=2.0cm]{geometry}');
   

   fprintf(fid,'\\usepackage{amsmath}\n');
   fprintf(fid,'\\usepackage{pdflscape}\n');
   fprintf(fid,'\\begin{document}\n');
   %fprintf(fid,'\\begin{landscape}\n');
end

fprintf(fid,'\\begin{equation}\n');
fprintf(fid,'\\begin{aligned}\n');
for i=1:size(rules,2)
    str_rule = strcat('&',num2str(R.c(i)),': h_{',num2str(i),...  
                      '} \\leftrightarrow ');
    first_literal = 0;
    for k=1:size(rules,1)
        ninx = rules(k,i);
        if ninx<1, continue; end
        if first_literal,  str_rule = [str_rule,' \\wedge ']; end
        first_literal = 1;
        str_rule = [str_rule, ' '];
        if R.r(k,i)<0
            str_rule = [str_rule, ' \\neg '];
        end
        [k,ninx]
        str_rule = [str_rule,' ', conf.vnames{k},'_',conf.relations{k},'_',conf.vvalues(k).vl{ninx}];    
        
    end
    fprintf(fid, [strrep(str_rule,'_','\\_'),'\\\\']);
    fprintf(fid,'\n');

    if rem(i,30)==0
    fprintf(fid,'\\end{aligned}\n');
    fprintf(fid,'\\end{equation}\n');
    if i<size(rules,2)
    fprintf(fid,'\\begin{equation}\n');
    fprintf(fid,'\\begin{aligned}\n');
    end
    end 
end 

fprintf(fid,'\\end{aligned}\n');
fprintf(fid,'\\end{equation}\n');

if conf.full_doc
    %fprintf(fid,'\\end{landscape}\n');
   fprintf(fid,'\\end{document}\n');
end
fclose(fid);
end