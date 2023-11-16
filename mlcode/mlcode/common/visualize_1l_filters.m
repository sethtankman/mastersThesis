function visualize_1l_filters(filters,num,row,col,normalize,row_order,img_name)
%Visualize filter
if nargin<6, row_order=1; end
filters = filters';
if strcmp(normalize,'minmax')
   MN = min(min(filters));
   MX = max(max(filters));
   filters = (filters-MN)/(MX-MN);
elseif strcmp(normalize,'sigmoid')
   filters = logistic(filters);
elseif strcmp(normalize,'single_minmax')
   MN = min(filters,[],2);
   MX = max(filters,[],2);
   filters = bsxfun(@rdivide,bsxfun(@minus,filters,MN),(MX-MN));
end

if nargin<7
    show_images(filters,min(num,size(filters,1)),row,col,row_order);
else
    save_images(filters,min(num,size(filters,1)),row,col,img_name,row_order);    
end
end

