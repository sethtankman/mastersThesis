function [pred_list,obj_list,data,rules] = kinship_data()
if ispc
    HOME = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
else
    HOME = getenv('HOME');
end
dat_file = strcat(HOME,'/WORK/Data/DS_Data/kinship/kinship.data');

obj_list = get_object_list(dat_file);
pred_list = {'wife', 'husband','mother', 'father',...
             'daughter','son', 'sister', 'brother',...
             'aunt','uncle','niece','nephew'};
[rules,data] = get_data(dat_file,pred_list,obj_list);
end

function obj_list = get_object_list(dat_file)
    obj_list = {};
    fid = fopen(dat_file);
    tline = fgetl(fid);
    while ischar(tline)
        if ~isempty(tline)
            i1 = strfind(tline,'(');
            i2 = strfind(tline,',');
            i3 = strfind(tline,')');
            
            n1 = strtrim(tline(i1+1:i2-1));
            n2 = strtrim(tline(i2+1:i3-1));


            if isempty(strmatch(n1,obj_list))
                obj_list = [obj_list,n1];
            end
            if isempty(strmatch(n2,obj_list))
                obj_list = [obj_list,n2];
            end
        end
        tline = fgetl(fid);
    end
    
end

function [rules,data] = get_data(datfile,pred_list,obj_list)
    fid = fopen(datfile);
    tline = fgetl(fid);
    rules = [];
    data = [];
    while ischar(tline)
        if ~isempty(tline)
            i1 = strfind(tline,'(');
            i2 = strfind(tline,',');
            i3 = strfind(tline,')');

            p  = strmatch(strtrim(tline(1:i1-1)),pred_list);
            n1 = strmatch(strtrim(tline(i1+1:i2-1)),obj_list);
            n2 = strmatch(strtrim(tline(i2+1:i3-1)),obj_list);

            rules = [rules;[n1, n2,p]];
        end
        tline = fgetl(fid);
    end

    obj_num = numel(obj_list);
    pred_num = numel(pred_list);
    
    for i =1:size(rules,1)
        n1 = rules(i,1);
        n2 = rules(i,2);
        d = zeros(2*obj_num+2*pred_num,1);
        d(n1) = 1;
        d(obj_num + n2) = 1;

        for j=1:size(rules,1)
            
            if n1==rules(j,1) && n2==rules(j,2)
                d(2*obj_num+2*(rules(j,3)-1)+1) = 1;
            end
            if n2==rules(j,1) && n1==rules(j,2)
                d(2*obj_num+2*(rules(j,3)-1)+2) = 1;
            end
           
        end
        data = [data,d];
    end    
end


