clear;


load('DT_Diagnosis.mat','net'); % NAMAC 
inputMin = net.inputs{1}.processSettings{1}.xmin;
inputMax = net.inputs{1}.processSettings{1}.xmax;
outputMin = net.outputs{net.numLayers}.processSettings{1}.xmin; 
outputMax = net.outputs{net.numLayers}.processSettings{1}.xmax;

% randInput = (inputMax-inputMin).*rand(3,10) + inputMin;

input = [350,inputMax(1),inputMax(1),inputMax(1),inputMin(1),inputMin(1),inputMin(1),inputMin(1);
    351,inputMax(2),inputMin(2),inputMin(2),inputMax(2),inputMax(2),inputMin(2),inputMin(2);
    600,inputMin(3),inputMax(3),inputMin(3),inputMax(3),inputMin(3),inputMax(3),inputMin(3);]
output = net(input);
h4_1 = output > (outputMax+outputMin)/2;
