function cr_en = cent(x,y)
 cr_en = mean(sum(-x.*log(y+0.0000000001) -(1-x).*log(1-y+0.0000000001),1));
end
