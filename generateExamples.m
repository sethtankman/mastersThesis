clear; 

% Settings
SZ = 50;

load('simp.mat', 'net'); % train model
examples = rand(3,SZ);

validation = zeros(1, SZ);
for i = 1:SZ
    validation(1,i) = net(examples(:, i))
end

output = [examples; validation]

writematrix(output, "trainingData.xls");