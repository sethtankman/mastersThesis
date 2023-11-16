function outp = disgroup_softmax_sampl(inp,d_ranges)
outp = zeros(size(inp));
Num =numel(d_ranges);
[ROW,SZ] = size(inp);
start_inx = 1; 
for i=1:Num
    end_inx = start_inx+d_ranges(i)-1;
    % row: start_inx-1 + softmax_(inp(start_inx:end_inx,:))
    % col: 1:SZ
    inx = softmax_(inp(start_inx:end_inx,:));
    outp(start_inx-1 + inx +  [0:SZ-1]*ROW )=1;
    
    %check(outp(start_inx:end_inx,:),inx);
    start_inx = end_inx+1;
end
end

function check(outp,inx)
    if sum(sum(find(sum(outp)>1))), fprintf('Error\n'); pause; end
    if sum(sum(find(sum(outp)==0))), fprintf('Error\n'); pause; end
    oinx = [];
    for i=1:size(outp,2)
        oinx = [oinx,find(outp(:,i))];
    end

    if sum(sum(oinx ~= inx))> 0, fprintf('Error\n'); pause; end
end