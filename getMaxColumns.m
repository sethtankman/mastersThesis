function [maxCols] = getMaxColumns(network)
    maxCols = 0;
    layer = 1;
    while(layer < network.numLayers)
        if(maxCols < network.layers{layer}.size)
            maxCols = network.layers{layer}.size;
        end
        layer = layer + 1;
    end
end