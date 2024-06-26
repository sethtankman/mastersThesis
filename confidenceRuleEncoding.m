clear;

% load models and data
confRules = readtable("confidenceRules1.csv");
trainData = readmatrix("trainingData.xls");
% load('DT_Diagnosis.mat','net'); % NAMAC 
load('simp.mat', 'net'); % simple example

% Hyperparameters
top_x = 2; % TODO: What's this?
hidNuma = 1; % number of units added to the hidden layer
eNum = 10; % Number of epochs
SZ = 50; % Number of examples in the training data
lr = 0.2;


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
allLayerRules = dictionary;
allX = dictionary;
allW = dictionary;
allB = dictionary;
row = 1;

% Build New Network and Forward Propagation
x = trainData(1:3,1:SZ); % b = 1, bNum = 1, snum = SZ, based on dna_exp>prop_eblm
allX(1) = {x};
while row <= size(confRules, 1)
    layer = str2num(cell2mat(extract(confRules{row, 1}, 3)));
    layerRules = confRules(str2num(cell2mat(extract(confRules{:,1}, 3))) == layer,:);

    cv = layerRules{:,2};
    Wrules = repmat(layerRules{:,2},1,size(layerRules,1)).*layerRules{:,3:end}; % Weights from Rules
    %hidBr = -sum(layerRules{:,2:end}(layerRules{:,2:end}>0))+0.5; %%% check this one % TODO: Copied. explain me.
    allLayerRules(layer) = {Wrules};
    hidBr = net.b{layer};
    %weightCells = num2cell(zeros(net.numLayers));
    %weightMatrix = zeros(net.layers{1}.size,net.inputs{1}.size);
    %matRow = 1;
    if(layer == 1)
        visNum = net.inputs{1}.size;
    else
        visNum = net.layers{layer-1}.size+hidNuma;
        Wrules = [Wrules,1/max(visNum,hidNuma)*randn(1,hidNuma)];
    end
    Wadded = (1/max(visNum,hidNuma))*randn(hidNuma,visNum); % Randomize starting weights to new nodes
    hidBa = zeros(hidNuma,1); % Set initial bias to zero for added nodes
    if(net.numLayers == layer)
        Wadded = []; % Randomize weights for last layer (no new nodes added, just new weights)
        hidBa = []; % We do not add biases if we are not adding nodes.
    end
    % visB = zeros(visNum,1);
    W = [Wrules; Wadded];
    allW(layer) = {W};
    hidB = [hidBr;hidBa];
    allB(layer) = {hidB};
    x = activation(myRBM.layers{layer}.transferFcn, bsxfun(@plus,W*x,hidB));
    allX(layer+1) = {x}; 
    row = row + size(layerRules, 1);
end
actuals = trainData(4,:);

for epoch = 1:eNum
    mse = mean((actuals - x).^2);
    for exampleNum = 1:SZ
        DWa = actuals - x;
        err = DWa(exampleNum);
        mse = mean((actuals - x).^2);
        
        % BackPropagation
        for lnum = layer:-1:1
            layerW = allW{lnum}; % TODO: Debugging purposes only- Erase me.
            Wr = zeros(size(allW{lnum}));
            Wr(1:size(allLayerRules{lnum},1),1:size(allLayerRules{lnum},2)) = allLayerRules{lnum};
            Wadded = allW{lnum} - Wr;
            err = Wadded.*err'; % TODO: f'(z) = 1 only when f(z) = z.
            %loss = mean(lr*allX{lnum}.*DWa, 2);
            Z = allX{lnum}(:, exampleNum);
            rhs = lr*Z'.*err; % TODO: Debugging only. Erase me.
            allW{lnum} = allW{lnum} - lr*Z'.*err; % TODO: Should we update by the mean or one sample at a time?
            layerW = allW{lnum}; % TODO: Debugging purposes only- Erase me.
        end
        
        %Forward propagation
        x = trainData(1:3,1:SZ); % b = 1, bNum = 1, snum = SZ, based on dna_exp>prop_eblm
        for layer = 1:size(allW.entries, 1)
            W = allW{layer};
            hidB = allB{layer};
            x = activation(myRBM.layers{layer}.transferFcn, bsxfun(@plus,W*x,hidB));
        end
    end
end

%{
    DCV = zeros(size(T));
    DWa = zeros(size(Wadded));
    DVB = zeros(size(visB));
    DHBa = zeros(size(hidBa));
    
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
    
    % resetting rules to 1,0,or -1 
    Wrules = bsxfun(@rdivide, Wrules,cv);

    while running && epoch < eNum
        rec_err = 0;
        epoch = epoch + 1;
        x = trainData(1:3,(1-1)*SZ + 1:min(1*SZ,SZ)); % b = 1, bNum = 1, snum = SZ, based on dna_exp>prop_eblm

        W = [Wadded,bsxfun(@times,Wrules,cv)]; %%% merging weights [Wa,bsxfun(@times,Wr,cv)]
        hidB = [hidBa;hidBr.*cv]; % TODO: Should the bias be multiplied by the confidence?
        %% soft infer
        hidIp  = bsxfun(@plus,W'*x,hidB);
        [hidP,hidPs]  = infer(hidIp,'stochastic');
        hidNs = hidPs;% hidNs = random samples from hidIp

        % since gNum = 1, we forgo the following section's for loop
        % We will also forgo the next section entirely, since it handles
        % bidirectional neural nets.
        %% gNum loop
        % visN  = bsxfun(@plus,W*hidNs,visB); % hidNs = output of activation function
        % [visN,visNs] = infer(visN,'stochastic'); % visN = output of activation function on the visible layer.

        % hidIn  = bsxfun(@plus,W'*visNs,hidB);
        % [hidN,hidNs] = infer(hidIn,'stochastic');
        % rec_err = rec_err + sqrt(sum(mean(visN - x).^2));
        %a = a + mean(visNs(end,:) == x(end,:));
        
        %% update values
        % Loss = inputs * hidden_activations -
        % random_samples_from_visual_activations (x') * hidden_activations_the_second_time (hidP') /
        % size
        % diffa = (x*hidP(1:hidNuma,:)' - visNs*hidN(1:hidNuma,:)')/SZ; % TODO: Substitute visNs for actuals
        % Loss = actuals - activations.
        actuals = trainData(4,:); % PROBLEM!  comparing activation values for hidden nodes with activation value for entire network!!!
        % TODO: Probably have to do repmat later on for multiple added hidden units
        % W = W - lr * J'(W)
        % DW_0 = w . DW_1 . f'(z)
        diffa = actuals - hidP(1:hidNuma,:); 
        DWa = lr*(diffa - 0*Wadded) + 0*DWa; % ct = 0, mm = 0
        Wadded = Wadded + DWa; % Wa = Wadded
        DHBa = lr*mean(actuals - hidP(1:hidNuma,:),2); % aNum = hidNuma
        hidBa = hidBa + DHBa; % DHBa should be a single value, is a 1x3 vector
        % pre_activation.*activations - pre_activation'.*activations'
        %DCV =lr* mean(hidIp(hidNuma+1:end,:).*hidP(hidNuma+1:end,:) - hidIn(hidNuma+1:end,:).*hidN(hidNuma+1:end,:),2);
        % actuals - 
        mvar =repmat(actuals,size(hidP,1)-1,1);
        mvar2 = hidP(hidNuma+1:end,:);
        DCV = lr*mean(repmat(actuals,size(hidP,1)-1,1) - hidP(hidNuma+1:end,:),2)
        cv = cv + DCV;
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
%}