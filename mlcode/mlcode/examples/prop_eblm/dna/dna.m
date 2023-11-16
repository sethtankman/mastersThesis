function [dat,lab] = dna()
if ispc
    HOME = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
    HOME = getenv('HOME');
end    
vp = 'agtc';
ffile = strcat(HOME,'/WORK/Data/DS_Data/DNA_1/promoters.data');
fid = fopen(ffile);

dat = [];
lab = [];
tline = fgetl(fid);
while ischar(tline)
    l = tline(1);
    if l=='-'
        lab = [lab,0];
    else
        lab = [lab,1];
    end
    str = strsplit(tline,',');
    str = strtrim(str{end});

    d = zeros(57*4,1);
    p = 0;
    for s = str        
        d(p*4+strfind(vp,s)) = 1;
        p=p+1;
    end

    dat = [dat,d];
    tline = fgetl(fid);
end

fclose(fid);

end