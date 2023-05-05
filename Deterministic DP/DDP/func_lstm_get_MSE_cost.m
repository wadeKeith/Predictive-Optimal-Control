function [MSE_total,cost,ls] = func_lstm_get_MSE_cost(df)
    
    [cost,v_predict_all,x_ls,action_ls] = func_lstm_get_cost(df);
    MSE_each = zeros(length(v_predict_all),1);
    for i=1:length(v_predict_all)
        MSE_each_a = 0;
        for j = 1:5
            MSE_each_a = MSE_each_a+(v_predict_all(i,j+1)-df(i+j,1))^2;
        end
        MSE_each(i) = sqrt(MSE_each_a/5);
    end
    MSE_total = sum(MSE_each)/(length(v_predict_all));
    ls = [x_ls;action_ls];
end

