function model = load_deepnet(path,name)
i=0; 
while 1
    i = i+1;
    inx = strfind(name,strcat('rbm',num2str(i)));
    if isempty(inx), return; end
    if name(inx-1)=='c'
        load(strcat(path,'CRBM',num2str(i),'/',name(inx-1:end)));
        model(i) = rbm;
    else
        load(strcat(path,'RBM',num2str(i),'/',name(inx:end)));
        model(i) = rbm;
    end
    clear rbm;
end
end

