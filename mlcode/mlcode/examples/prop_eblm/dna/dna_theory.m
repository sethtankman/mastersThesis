function promoter = dna_theory()
%% prepare DNA promoter data
inds = {};
for i = [-50:-1,1:7]
    if i>0
        s= '+';
    else
        s= '-';
    end
    inds = [inds,strcat('p',s,num2str(abs(i)))];
end


m35 = [];
%minus_35
m35_strs = {'p-37=c, p-36=t, p-35=t, p-34=g, p-33=a, p-32=c',
        'p-36=t, p-35=t, p-34=g, p-32=c, p-31=a',
        'p-36=t, p-35=t, p-34=g, p-33=a, p-32=c, p-31=a',
        'p-36=t, p-35=t, p-34=g, p-33=a, p-32=c'};

for i = 1:numel(m35_strs)
    m35 = [m35,convert_dna_rule_2vec(m35_strs{i},inds)];
end


m10 = [];
m10_strs = {'p-14=t, p-13=a, p-12=t, p-11=a, p-10=a, p-9=t',
            'p-13=t, p-12=a, p-10=a, p-8=t',
            'p-13=t, p-12=a, p-11=t, p-10=a, p-9=a, p-8=t',
            'p-12=t, p-11=a, p-7=t'};

for i = 1:numel(m35_strs)
    m10 = [m10,convert_dna_rule_2vec(m10_strs{i},inds)];
end

con = [];
con_strs = {'p-47=c, p-46=a, p-45=a, p-43=t, p-42=t, p-40=a, p-39=c,p-22=g, p-18=t, p-16=c, p-8=g,  p-7=c,  p-6=g, p-5=c,p-4=c,  p-2=c,  p-1=c',
            'p-45=a, p-44=a, p-41=a',
            'p-49=a, p-44=t, p-27=t, p-22=a, p-18=t, p-16=t, p-15=g,p-1=a',
            'p-45=a, p-41=a, p-28=t, p-27=t, p-23=t, p-21=a, p-20=a,p-17=t, p-15=t, p-4=t'
            };
    
for i = 1:numel(m35_strs)
    con = [con,convert_dna_rule_2vec(m35_strs{i},inds)];
end


%contact  :- minus_35, minus_10
contact = [];
for i = 1:size(m35,2)
    for j = 1:size(m10,2)
        contact = [contact,m35(:,i)+m10(:,j)];
    end
end
contact(contact>0)=1;

%promoter :- contact, conformation.
promoter = [];
for i = 1:size(contact,2)
    for j = 1:size(con,2)
        promoter = [promoter,contact(:,i)+con(:,j)];
    end
end

promoter(promoter>0)=1;

end