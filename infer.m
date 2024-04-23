% Copied from ./mlcode/mlcode/rbm/infer.m by Long Tran
% Used in confidenceRuleEncoding.m
function [out,samples] =  infer(in,type)
if strcmp(type,'stochastic')
    out = logistic(in);
    samples = 1.0*(out>rand(size(out)));
elseif strcmp(type,'deterministic')
    samples = zeros(size(in));
    samples(in>0) = 1;
    out = samples;
end
end