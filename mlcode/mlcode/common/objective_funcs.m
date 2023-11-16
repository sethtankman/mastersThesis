if strcmp(obj_fnc,'mle')
    cost_fnc = @llh;    
elseif strcmp(obj_fnc,'mse')
    cost_fnc = @mse;
elseif strcmp(obj_fnc,'cent')
    cost_fnc = @cent;
else
    fprintf('Error!! No cost function is set!!\n');
end