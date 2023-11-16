function D = refine_data(D)
    D(union(isnan(D(:)),isinf(D(:))))=0;
end

