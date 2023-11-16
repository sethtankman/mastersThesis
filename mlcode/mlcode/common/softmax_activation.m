function A = softmax_activation( softmax_group)
A = exp(softmax_group);
A = A./repmat(sum(A,2),1,size(A,2));
for i=1:size(A,1)
    A(i,:) = cumsum(A(i,:))>rand();
    m = max(A(i,:));
    inx = find(A(i,:)==m,1,'first');
    A(i,:) = 0;
    A(i,inx) = 1;
end
end

