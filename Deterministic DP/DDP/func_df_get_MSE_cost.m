function [MSE_total,cost,ls] = func_df_get_MSE_cost(df)
    
    MSE_each = zeros(length(df)-5,1);
    for i=1:length(df)-5
        MSE_each_a = 0;
        for j = 1:5
            MSE_each_a = MSE_each_a+(df(i,j+1)-df(i+j,1))^2;
        end
        MSE_each(i) = sqrt(MSE_each_a/5);
    end
    MSE_total = sum(MSE_each)/(length(df)-5);
    [cost,x_ls,action_ls] = func_df_get_total_cost(df);
    ls = [x_ls;action_ls];
end

