% By Addison Shuppy
% PRE: Given an activation function "name" and input "x"
% POST: Returns activation value
% Used in: ConfidenceRuleEncoding.m
function A = activation(name, x)
    A = 0;
    if name == 'purelin'
        A = x;
    else
        disp("Error, activation function "+name+" is not implemented")
    end
end