simp = network(1, 1,[1],[1],0, 1);
simp.inputs{1}.size = 3;
simp.layers{1}.size = 1;
simp = setwb(simp, [[1.5],[1, 1, 1]]);
view(simp)
save simp