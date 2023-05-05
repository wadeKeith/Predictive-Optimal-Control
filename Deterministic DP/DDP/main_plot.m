clear all
clc

% data = csvread("initial_data.csv",2,1);
data = csvread("1 (4726).csv",1,3);
parpool('local',28);
predictor_num = 5;
rand_predictor_num = 5;
load net.mat
predict_v_str_rand_all = zeros(length(data),6,rand_predictor_num);
predict_v_str_acc_all = zeros(length(data),6,predictor_num);
MSE = zeros(1,predictor_num+rand_predictor_num);
cost_out = zeros(1,predictor_num+rand_predictor_num);
parfor i =1:(predictor_num)
    sec=i;
    [predict_v_str_acc,MSE_total,cost,acc_ls] = func_acc_getMSE_cost(sec,data);
    MSE(i) = MSE_total;
    cost_out(i) = cost;
    predict_v_str_acc_all(:,:,i) = predict_v_str_acc;
    acc_ls_all(:,:,i) = acc_ls;
end
parfor i =1:(rand_predictor_num)
    num=i;
    [predict_v_str_rand,MSE_total,cost,random_ls] = func_random_w(num,data);
    MSE(i+predictor_num) = MSE_total;
    cost_out(i+predictor_num) = cost;
    predict_v_str_rand_all(:,:,i) = predict_v_str_rand;
    random_ls_all(:,:,i) = random_ls;
end
%%
[constant_speed,real_time] = func_build_cs_real_data(data);

[MSE_cs,cost_cs,cs_ls] = func_df_get_MSE_cost(constant_speed);
% [MSE_GPR,cost_GPR] = func_df_get_MSE_cost(csvread("GRP_v.csv"));
[MSE_rt,cost_rt,rt_ls] = func_real_time_get_MSE_cost(real_time);
%%
[MSE_LSTM,cost_LSTM,lstm_ls] = func_lstm_get_MSE_cost(data);
MSE = [MSE MSE_cs MSE_LSTM MSE_rt];
cost_out = [cost_out cost_cs cost_LSTM cost_rt];




delete(gcp('nocreate'));