 bfunction R = rbm_energy_search_ext(model,conf,data)
% Son N. Tran
% R.r: vNum x number_of_rules --> (-1,0,1) matrix
% R.c: 1xnumber_of_rules      --> real positive values
    
[visNum,hidNum] = size(model.W);
dsize = size(data,2);
R.c = [];
R.r = [];
for hinx=1:hidNum
    %    for i =1:dsize
        s = data;%(:,i);
        r = energy_search(model.W(:,hinx),model.hidB(hinx),s);
        if isempty(r), continue; end
        R.c = [R.c,r.c];
        R.r = [R.r,r.r];
        %    end
end
end

function r = energy_search(w,b,data)
     r.r = [];
     r.c = [];

     %%%
     %%% TODO TODO 
    
end