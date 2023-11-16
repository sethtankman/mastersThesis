function show_images(Is,num,img_row,img_col,row_order)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show num images in Is                                                   %
% sontran2012                                                             %
% row_order: the images are vectorized row by row (not col by col as      %
% standard matlab a(:)                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5, row_order=true; end
if num>1000, return; end;
if num> size(Is,1), num = size(Is,1); end;
col = max(floor(sqrt(num)),1);
row = ceil(num/col);
gap = 2;
pos = ones(1,col*row);
pos = cumsum(pos);
pos = reshape(pos,[col row])';
bigImg = 0.5*ones(row*img_row + (row-1)*gap,col*img_col + (col-1)*gap);
for i=1:row
    for j=1:col
        y = 1 + (i-1)*(img_row+gap);
        x = 1 + (j-1)*(img_col+gap);        
        if pos(i,j) <= num
            if row_order, bigImg(y:y+img_row-1,x:(x+img_col-1)) = reshape(Is(pos(i,j),:),[img_col,img_row])';
            else
                bigImg(y:y+img_row-1,x:(x+img_col-1)) = reshape(Is(pos(i,j),:),[img_row,img_col]);
            end            
        end
    end
end
imshow(bigImg);

end

