% In this code we treat the matrix: W as IxJ, D as I or J x sNum
% Becareful when apply to the old code (need to change the old code)
if ~exist('v_unit','var'), v_unit = 'binary'; end
if ~exist('h_unit','var'), h_unit = 'binary'; end

if strcmp(v_unit,'binary')
    hid2vis = inline('logistic(D)','D');
    vis_sample = inline('double(D>rand(size(D)))','D');
elseif strcmp(v_unit,'gaussian')
    hid2vis = inline('D','D');  
    vis_sample = inline('D + randn(size(D))','D');
end

if strcmp(h_unit,'binary')
    vis2hid = inline('logistic(D)','D');
    hid_sample = inline('double(D>rand(size(D)))','D');
elseif strcmp(h_unit,'gaussian')    
    vis2hid = inline('D','D');  
    hid_sample = inline('D + randn(size(D)','D');
elseif strcmp(h_unit,'relu')   
    %vis2hid = inline('bsxfun(@plus,transpose(W)*D,b)','W','b','D');
    vis2hid = inline('max(0,D + rand(size(D)).*sqrt(logistic(D)))','D');
    hid_sample = inline('D','D');
end