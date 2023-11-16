function s_m = discrete2softmax(inp,nmax)
% Convert discrete data into softmax
% inp: nxm (m is number of samples)
sNum = max(size(inp));
s_m = zeros(nmax,sNum);

s_m(inp + [0:sNum-1]*nmax) = 1;
end

