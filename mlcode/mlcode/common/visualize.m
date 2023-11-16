function visualize(model,num,row,col,normalize,img_name)
    higher_bases = eye(size(model(end).W,2));
    for i=size(model,2):-1:1
        higher_bases = model(i).W*higher_bases;        
    end        
     if nargin<6
         visualize_1l_filters(higher_bases,num,row,col,normalize,1);     
     else
         visualize_1l_filters(higher_bases,num,row,col,normalize,1,img_name);     
     end
end

