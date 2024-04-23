% By Addison Shuppy
% PRE: Given a valid neural network "network",
% POST: Computes the maximum size of the layers of "network" returns the 
% "maxCols" needed for a table.
% Used in knowledge_extraction.m, knowledge_extraction_b.m,
% knowledge_extraction_c.m, knowledge_extraction_d.m
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