function [avg_min_en,min_en] = min_energy(model,data)
% Compute minimized energy (over h) of data in the ECM model
% Son T
%
if isempty(data), fprintf('No data!!'); return; end

depth = size(model,1);
SZ = size(data,2)
min_en = zeros(SZ,1);

for i=1:depth 
    hidI = bsxfun(@plus,model.W'*data,model.hidB);
    hidO = 1*(data>0);
    
    min_en = min_en + sum(hidI.*hidO,1);
    data = hidO;
end

min_en = -min_en;
avg_min_en = mean(min_en)
end