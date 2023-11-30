clear; 

% Settings
SZ = 50;

load('simp.mat', 'net'); % train model
iw = net.IW{1,1}
% net.IW{1,1} = net.IW{1,1} + rand(size(net.IW{1,1}), "double"); % Perterb the weights, making this a hypothetical "true network"
examples = rand(3,SZ);

validation = zeros(1, SZ);
for i = 1:SZ
    validation(1,i) = net(examples(:, i));
    if (mod(i, 20) == 19)
        validation(1,i) = validation(1,i) + rand(1, "double"); % Perterb ~5% of the outputs
    end
end


output = [examples; validation];

writematrix(output, "trainingData.xls");