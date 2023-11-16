function imrule2latex(T,R,paper_dir)
% write rule to latex file
% sontran2013
% Save imgs
number = {'Zero','One','Two','Three','Four','Five','Six','Seven','Eight','Nine'};

vis_dir = strcat(paper_dir,'imgs/');
if ~exist(vis_dir,'dir'), mkdir(vis_dir); end
fid = fopen(strcat(paper_dir,'mnist_l1_rule.tex'),'w');
for i=1:size(R.r,1)
    img = reshape(R.r(i,1:end-1),[28,28]); %*R.c(i)
    img = vec2mat(R.r(i,1:end-1),28); %*R.c(i)
    %img = logistic(img);
        img = (img+1)/2;
    %img(img<0) = 0;
    imwrite(img,strcat(vis_dir,'r_',num2str(i),'.PNG'),'png');
end
fprintf(fid,'\\documentclass{article}\n');
fprintf(fid,'\\usepackage{graphicx}\n');
fprintf(fid,'\\usepackage{amsmath}\n');
fprintf(fid,'\\begin{document}\n');
%fprintf(fid,'\\begin{table}[ht]\n');
%fprintf(fid,'\\begin{tabular}{lc}\n');
for i=1:min(size(T.r,1),10)
   fprintf(fid,'$%.3f: \\text{%s}$ & $\\leftrightarrow$ ',R.c(i),number{i});                
   rind = find((T.r(i,1:end-1))>0); 
   
   count = 0;
   for j=1:size(rind,2)
       if sum(R.r(rind(j),:).^2)<5, continue; end
       if j>1           
           fprintf(fid,' $\\wedge$ ');           
       end 
       fprintf(fid,'\\includegraphics[width=0.05\\textwidth]{%s}',strcat(vis_dir,'r_',num2str(rind(j)),'.PNG'));
       count  = count+1;
       if rem(count,8)==0, fprintf(fid,' \\\\ '); end
       %if count>5, break; end
   end   
   fprintf(fid,'\\\\ \n');
end
       
%fprintf(fid,'\\end{tabular}\n');
%fprintf(fid,'\\end{table}\n');
fprintf(fid,'\\end{document}\n');
fclose(fid);
end

