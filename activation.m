function A = activation(name, x)
    A = 0;
    if name == 'purelin'
        A = x;
    else
        disp("Error, activation function "+name+" is not implemented")
    end
end