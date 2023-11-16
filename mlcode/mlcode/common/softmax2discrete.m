function D = softmax2discrete( S,Vals )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert softmax to col-array of discrete value     %
% S: softmax                                         %
% Vals: list of possible values                      %
% sontran2012                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[dummy out] = max(S');
out = out';
D = zeros(size(out));
for i=1:size(out,1)
    D(i) = Vals(out(i));
end
end

