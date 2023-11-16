clear;

% load models and data
T = readtable("confidenceRules1.csv");
% load('DT_Diagnosis.mat','net'); % NAMAC 
load('simp.mat', 'net'); % simple example

% Hyperparameters
top_x = 2;
hidNuma = 1;
eNum = 10;
SZ = 50;


% Construct new neural network based on rules.
myRBM = network;
myRBM.numInputs = net.numInputs;
myRBM.inputs{1}.size = net.inputs{1}.size;
myRBM.numLayers = net.numLayers;
net.numLayers
for layer = 1:net.numLayers
    myRBM.layers{layer}.size = net.layers{layer}.size + hidNuma;
    myRBM.layers{layer}.transferFcn =  net.layers{layer}.transferFcn;
end
myRBM.biasConnect = ones(net.numLayers, 1); % all layers have a bias.
myRBM.inputConnect = zeros(net.numLayers, 1);
myRBM.inputConnect(1) = 1; % connect input to the first hidden layer.
myRBM.layerConnect = net.layerConnect;
myRBM.outputConnect = net.outputConnect;
%myRBM.b = net.b; % TODO: Doesn't account for hidden nodes.

%Initializations
trainData = rand(3,SZ);
prevLayer = 0;
for row = 1:size(T, 1)
    layer = str2num(cell2mat(extract(T{row, 1}, 3)));
    if(layer ~= prevLayer)
        if(prevLayer ~= 0)
            weightCells{prevLayer+1, prevLayer} = weightMatrix;
            if(prevLayer == 1)
                %myRBM.IW{1,1} = weightMatrix; % myRBM.IW is a 2x1 cell matrix with (1,1) = a 3x3 weight matrix
            end
            weightMatrix = zeros(net.layers{layer}.size,net.layers{layer-1}.size);
            matRow = 1;
        end
        prevLayer = layer;
    end
    layerRules = T(str2num(cell2mat(extract(T{:,1}, 3))) == layer,:);

    cv = layerRules{:,2};
    Wrules = repmat(layerRules{:,2},1,net.inputs{1}.size).*layerRules{:,3:end}; 
    %weightCells = num2cell(zeros(net.numLayers));
    %weightMatrix = zeros(net.layers{1}.size,net.inputs{1}.size);
    %matRow = 1;
    visNum = 0;
    if(layer == 1)
        visNum = net.inputs{1}.size;
    else
        visNum = net.layers{layer-1}.size;
    end
    Wadded = (1/max(visNum,hidNuma))*randn(visNum,hidNuma);
    visB = zeros(visNum,1);
    hidBa = zeros(hidNuma,1);
    
    DCV = zeros(size(T));
    DWa = zeros(size(Wadded));
    DVB = zeros(size(visB));
    DHBa = zeros(size(hidBa));
    
    lr = [0.2,0.4,0.6];
    
    running = 1;
    epoch = 0;
    max_train_acc_gibbs = 0;
    max_train_acc_cond  = 0;
    max_eval_acc_gibbs  = 0;
    max_eval_acc_cond   = 0;
    logs = {[],[],[],[],[]};
    
    eval_max = 0;
    stop_count = 0;
    lr_decay_count= 0;
    
    while running && epoch < eNum
        rec_err = 0;
        epoch = epoch + 1;
        for b = 1:SZ
            x = trainData(:,(b-1)*SZ + 1:min(b*SZ,SZ)); % snum = SZ, based on dna_exp>prop_eblm
    
            W = [Wadded,Wrules']; %%% merging weights
            hidB = [hidBa;net.b{layer,1}]; % Should the bias be multiplied by the confidence?
            %% soft infer
            hidIp  = bsxfun(@plus,W'*x,hidB);
            [hidP,hidPs]  = infer(hidIp,'stochastic');
            hidNs = hidPs;
    
            gNum = 1; % Set like this because dna_exp was.
            for g=1:gNum
                visN  = bsxfun(@plus,W*hidNs,visB);
                [visN,visNs] = infer(visN,'stochastic');

                hidIn  = bsxfun(@plus,W'*visNs,hidB);
                [hidN,hidNs] = infer(hidIn,'stochastic');
            end
            rec_err = rec_err + sqrt(sum(mean(visN - x).^2));
            %a = a + mean(visNs(end,:) == x(end,:));
            
            diffa = (x*hidP(1:hidNuma,:)' - visNs*hidN(1:hidNuma,:)')/SZ;
            DWa = lr*(diffa - 0*Wadded) + 0*DWa; % ct = 0, mm = 0
            Wadded = Wadded + DWa; % Wa = Wadded
            DHBa = lr*mean(hidP(1:hidNuma,:) - hidN(1:hidNuma,:),2); % aNum = hidNuma
            hidBa = hidBa + DHBa;
            %% update cv
            DCV =lr* mean(hidIp(hidNuma+1:end,:).*hidP(hidNuma+1:end,:) - hidIn(hidNuma+1:end,:).*hidN(hidNuma+1:end,:),2);
    
            cv = cv + DCV';
        end
    end
end

for row = 1:size(T, 1)
    layer = str2num(cell2mat(extract(T{row, 1}, 3)));
    if(layer ~= prevLayer)
        if(prevLayer ~= 0)
            weightCells{prevLayer+1, prevLayer} = weightMatrix;
            if(prevLayer == 1)
                %myRBM.IW{1,1} = weightMatrix; % myRBM.IW is a 2x1 cell matrix with (1,1) = a 3x3 weight matrix
            end
            weightMatrix = zeros(net.layers{layer}.size,net.layers{layer-1}.size);
            matRow = 1;
        end
        prevLayer = layer;
    end
    confidence = T{row,2};
    weights = T{row,3:net.layers{layer}.size+2};
    weights = weights.*repmat(confidence, 1,net.layers{layer}.size);
    weightMatrix(matRow,:) = weights;
    matRow = matRow + 1;
end
%myRBM.LW{2,1} = weightMatrix;

save("confidenceNetwork.mat", "myRBM")