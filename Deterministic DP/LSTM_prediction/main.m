clear all
clc

%% data process
get_data_or_not = 1;
if get_data_or_not
    load data_input.mat
else
    [XTrain,YTrain,XTest,YTest] = data_process();
end
%%
muX = mean(cat(2,XTrain{:}),2);
sigmaX = std(cat(2,XTrain{:}),0,2);
muY = mean(cat(2,YTrain{:}),2);
sigmaY = std(cat(2,YTrain{:}),0,2);


for n = 1:numel(XTrain)
    XTrain{n} = (XTrain{n} - muX) ./ sigmaX;
    YTrain{n} = (YTrain{n} - muY) ./ sigmaY;
end
for n = 1:numel(XTest)
    XTest{n} = (XTest{n} - muX) ./ sigmaX;
    YTest{n} = (YTest{n} - muY) ./ sigmaY;
end
%% train
%%
if_train = 0; % if wanna train,1,if wanna inference,0
if if_train
    numfeature_input = size(XTrain{1},1);
    num_output = size(YTrain{1},1);
    layers = [
    sequenceInputLayer(numfeature_input)
    lstmLayer(128)
    fullyConnectedLayer(num_output)
    lstmLayer(128)
    fullyConnectedLayer(num_output)
    regressionLayer];
    options = trainingOptions("adam", ...
    MaxEpochs=200, ...
    SequencePaddingDirection="left", ...
    Shuffle="every-epoch", ...
    Plots="training-progress", ...
    ValidationData={XTest,YTest},ValidationPatience=20,ExecutionEnvironment="auto");
    net = trainNetwork(XTrain,YTrain,layers,options);
else
    load net.mat
end
%% predict

Y_deduce = predict(net,XTest,SequencePaddingDirection="left");
%% visual accurary
for i = 1:size(YTest,1)
    rmse(i) = sqrt(mean((YTest{i} - Y_deduce{i}).^2,"all"));
end

figure(1)
histogram(rmse)
xlabel("RMSE")
ylabel("Frequency")
%%
for n =1:numel(YTest)
    Y_deduce_actual{n} = Y_deduce{n}.*sigmaY+muY;
    YTest{n} = YTest{n}.*sigmaY+muY;
end

idx = randperm(numel(Y_deduce),9);
figure(2)
for i = 1:9
    subplot(3,3,i)
    t = 1:length(Y_deduce_actual{idx(i)});
    plot(t,Y_deduce_actual{idx(i)})
    hold on
    plot(t,YTest{idx(i)})
    hold off
    xlabel('Time')
    ylabel('acc')
    legend('deduce','actul')
end









