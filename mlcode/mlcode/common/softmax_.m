function L = softmax_(inp)
% Softmax function
% inp : input to softmax unit~log (exp(inp)) (not exp)
% inp: nxm (n is the dimension of layer,m is the number of cases)
% sontran2014
inp_o = inp;
[n,m] = size(inp);
inp = exp(bsxfun(@minus,inp,max(inp)));
prob = bsxfun(@rdivide,inp,sum(inp));
p = cumsum(prob)>repmat(rand(1,m),n,1);
L = n + 1 - sum(p);
end
