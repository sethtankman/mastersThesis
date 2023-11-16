function r = convert_dna_rule_2vec(str,inds)
vp = 'agtc';
r = zeros(57*4,1);
strs = strtrim(strsplit(str,','));
for s = strs
    s = s{1};
    inx = strfind(s,'=');
    pos = s(1:inx-1);
    v   = s(inx+1:end);
    p = find(not(cellfun('isempty', strfind(inds,pos))));
    vl = strfind(vp,v);

    r((p-1)*4+vl) = 1;
end
end