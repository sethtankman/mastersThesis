function R = rbm_energy_rank_ext(model,conf)
% Son N. Tran
% R.r: vNum x number_of_rules --> (-1,0,1) matrix
% R.c: 1xnumber_of_rules      --> real positive values
    
[visNum,hidNum] = size(model.W);
R.c = [];
R.r = [];
for hinx=1:hidNum
    r = energy_rank(model.W(:,hinx),model.hidB(hinx));
    %r = total_decompose(model.W(:,hinx),model.hidB(hinx));
    R.c = [R.c,r.c];
    R.r = [R.r,r.r];
end
%% TODO: merge rules
end

function r = energy_rank(w,b)
    [~,rank] = sort(abs(w));
    r.r = [sign(w)];
    r.c = [sum(w(w>0))+b];
    for inx = rank'
        tmp_r = r.r(:,end);
        tmp_r(inx) = 0;
        tmp_c = r.c(end)-abs(w(inx));
        if tmp_c<=0, break; end
        r.r = [r.r,tmp_r];
        r.c = [r.c,tmp_c];
    end
    r.c = r.c-[r.c(2:end),0];
end

function r = total_decompose(w,b)
    r.r = [];
    r.c = [];
    for i=1:numel(w)
        tmp_r = zeros(size(w));
        tmp_c = abs(w(i));
        if w(i)>0
            tmp_r(i)=1;
        else
            tmp_r(i)=-1;
        end
        r.r = [r.r,tmp_r];
        r.c = [r.c,tmp_c];
    end
end

