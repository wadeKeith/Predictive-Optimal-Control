function [total_cost,v_predict_all,x_ls,action_op_list] = func_lstm_get_cost(df)
    %%
    load_HEV_parameters
    load net.mat
    %%
    %read predict vel data and real vel
    
    df = df(:,1:2);
    v_real = df(:,1);
    
    %%
    %some constant
    x_initial = 0.46;
    x_target = 0.6;
    W1 = 258;
    W2 = 400;
    W3 = 1;
    grade_sequence_all = 0*ones(1,length(v_real));
    action_op_list = zeros(1,(length(v_real)-5-1));
    x_ls = zeros(1,(length(v_real)-5));
    cost_ls = zeros(1,(length(v_real)-5));
    v_predict_all = zeros(length(v_real)-5,6);
    %calculate the cost
    [tor_req_r,rpm_sequence_r,~] = func_get_powertrain_sequence_from_v_sequence(v_real(1:length(v_real),1)',grade_sequence_all(1:length(v_real)),HEV);
    x_loop = x_initial;
    x_ls(1) = x_initial;
    for i = 1:(length(v_real)-5-1)
        v_predict_loop = v_real(i);
        a_predict_loop = df(i,2);
        feature_loop = [v_predict_loop;a_predict_loop];
        v_sequence = zeros(1,6);
        v_sequence(1) = v_real(i);
        for j =2:6
            a_predict = predict(net,feature_loop,SequencePaddingDirection="left");
            v_predict = v_predict_loop+a_predict*0.1;
            v_sequence(j) = v_predict;
            v_predict_loop = v_sequence(j);
            a_predict_loop = a_predict;
            feature_loop = [v_predict_loop;a_predict_loop];
        end
        v_predict_all(i,:) = v_sequence;
        tor_demand_r = tor_req_r(i);
        rpm_r = rpm_sequence_r(i);
        grade_sequence = grade_sequence_all(1,i:(i+(length(v_sequence)-1)));
        if tor_demand_r<0
            action = func_HEV_control_regen(x_loop,tor_demand_r,rpm_r,HEV);
        else
            action = func_find_action(x_loop,v_sequence,grade_sequence,x_target,W1,W2,W3,HEV);
        end
        action_op_list(i) = action;
        ne_x = func_HEV_system_dynamics(x_loop,action,tor_demand_r,rpm_r,HEV);
        rcost = W3*func_HEV_running_cost(action,tor_demand_r,rpm_r,HEV)+W2*(ne_x-x_target)^2;
        cost_ls(i) = rcost;
        
        x_loop = ne_x;
        x_ls(i+1) = ne_x;
    
    end
    x_n = x_ls(end);
    cost_finial = W1*(x_initial-x_n)^2;
    cost_ls =[cost_ls cost_finial];
    total_cost = sum(cost_ls);
    action_op_list = [0,action_op_list];
end