function [XTrain,YTrain,XTest,YTest] = data_process()
    data_num = length(dir('data\*.csv'));
    data_X = cell(data_num,1);
    data_Y = cell(data_num,1);
    
    for i = 1:data_num
        file_name = ['data\',sprintf('1 (%d).csv',i)];
        data_temple = csvread(file_name,1,3);
        [~,col] = size(data_temple);
        data_X(i,1)={data_temple(1:end-1,col-3:col-2)'};
        data_Y(i,1) = {data_temple(2:end,col-2)'};
    
    end
    
    numObservations_X = numel(data_X);
    numObservations_Y = numel(data_Y);
    idxTrain_X = 1:ceil(0.9*numObservations_X);
    idxTrain_Y = 1:ceil(0.9*numObservations_Y);
    idxTest_X = ceil(0.9*numObservations_X)+1:numObservations_X;
    idxTest_Y = ceil(0.9*numObservations_Y)+1:numObservations_Y;
    XTrain = data_X(idxTrain_X);
    YTrain = data_Y(idxTrain_Y);
    XTest = data_X(idxTest_X);
    YTest = data_Y(idxTest_Y);
end

