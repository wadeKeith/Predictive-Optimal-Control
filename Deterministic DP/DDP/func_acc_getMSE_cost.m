function [predict_v_str_acc,MSE_total,cost,ls] = func_acc_getMSE_cost(sec,df)

    acc = df(:,2);
    v_table = [df(:,1),zeros(length(df),5)];
    acc_1s = acc/sec;
    acc_table = zeros(length(v_table),5);
    for i = 1:length(v_table)-5
        a_loop = acc(i);
        for j = 1:5
            if (a_loop)^2 <6e-30
                acc_table(i,j) = 0;
            elseif (a_loop-acc_1s(i))^2<6e-30
                acc_table(i,j) = 0;
            else
                acc_table(i,j) = a_loop-acc_1s(i);
            end
            a_loop = acc_table(i,j);
    
        end
    end
    acc_table = [acc,acc_table];
    for i = 1:length(v_table)-5
        for j=1:5
            if v_table(i,j)+acc_table(i,j)<=50 && v_table(i,j)+acc_table(i,j)>=0
                v_table(i,j+1) = v_table(i,j)+acc_table(i,j)*0.1;
            elseif v_table(i,j)+acc_table(i,j)>50
                v_table(i,j+1) = 50;
            else
                v_table(i,j+1) = 0;
            end
        end
    end
    MSE_each = zeros(length(v_table)-5,1);
    for i=1:length(v_table)-5
        MSE_each_a = 0;
        for j = 1:5
            MSE_each_a = MSE_each_a+(v_table(i,j+1)-v_table(i+j,1))^2;
        end
        MSE_each(i) = sqrt(MSE_each_a/5);
    end
    MSE_total = sum(MSE_each)/(length(v_table)-5);
    [cost,x_ls,action_ls] = func_df_get_total_cost(v_table);
    ls = [x_ls;action_ls];
    predict_v_str_acc = v_table;
end

