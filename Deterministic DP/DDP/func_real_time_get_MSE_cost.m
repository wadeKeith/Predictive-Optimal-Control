function [MSE_total,cost_total,ls] = func_real_time_get_MSE_cost(df)
    load_HEV_parameters
    MSE_each = zeros(length(df)-5,1);
    for i=1:length(df)-5
        MSE_each_a = 0;
        for j = 1:5
            MSE_each_a = MSE_each_a+(df(i,j+1)-df(i+j,1))^2;
        end
        MSE_each(i) = sqrt(MSE_each_a/5);
    end
    MSE_total = sum(MSE_each)/(length(df)-5);



    seq_len_r = 5;
    x_initial_r = 0.46;
    x_target_r = 0.6;
    W1_r = 258;
    W2_r = 400;
    W3_r = 1;
    grade_sequence_all_r = 0*ones(1,length(df));
    % 
    %[~,cost_r] = func_find_action(x_initial_r,df(1:(length(df)-seq_len_r),1)',grade_sequence_all_r(1:(length(df)-seq_len_r)),x_target_r,W1_r,W2_r,W3_r,HEV);
    
    x_initial =x_initial_r;
    v_sequence =df(1:(length(df)-seq_len_r),1)';
    grade_sequence= grade_sequence_all_r(1:(length(df)-seq_len_r));
    x_target =x_target_r;
    W1=W1_r;
    W2 = W2_r;
    W3 = W3_r;
    %some constant
    xi=linspace(0.2,0.8,61);
    u_list = linspace(-200,200,401);
    %DP programming
    [tor_req,rpm_sequence,~] = func_get_powertrain_sequence_from_v_sequence(v_sequence,grade_sequence,HEV);
    J_F = zeros(length(xi),length(v_sequence)-1);

    
    % DP backward find the best cost
    for p = 1:length(xi)
        J_F(p,length(v_sequence)) = W1*(x_initial-xi(p))^2;
    end
    J_fc=griddedInterpolant(xi,J_F(:,length(v_sequence)));

    for i = 1:length(v_sequence)-2
        tor_demand = tor_req(length(v_sequence)-i);
        rpm = rpm_sequence(length(v_sequence)-i);
        for j = 1:length(xi)
            if tor_demand < 0
                motor_torque = func_HEV_control_regen(xi(j),tor_demand,rpm,HEV);
                %[~,~,input_is_valid] = func_HEV_input_constraint_satisfied(motor_torque,tor_demand,rpm,HEV);
                next_x = func_HEV_system_dynamics(xi(j),motor_torque,tor_demand,rpm,HEV);
                next_x_is_valid = func_HEV_soc_constraint_satisfied(next_x,HEV);
                if next_x_is_valid == true
                    J_ = J_fc(next_x);
                    cost = W3*func_HEV_running_cost(motor_torque,tor_demand,rpm,HEV)+W2*(next_x-x_target)^2 + J_;
                else
                    J_ = J_fc(0.8);
                    cost = W3*func_HEV_running_cost(motor_torque,tor_demand,rpm,HEV)+W2*(0.8-x_target)^2 + J_;
                end
            else
                u_min_cost = 1e8*ones(1,length(u_list));
                for k = 1:length(u_list)
                    if u_list(k)<tor_demand
                        motor_torque = u_list(k);
                        [~,~,input_is_valid] = func_HEV_input_constraint_satisfied(motor_torque,tor_demand,rpm,HEV);
                        next_x = func_HEV_system_dynamics(xi(j),motor_torque,tor_demand,rpm,HEV);
                        next_x_is_valid = func_HEV_soc_constraint_satisfied(next_x,HEV);
        
                        if input_is_valid == true || next_x_is_valid == true
                            J_ = J_fc(next_x);
                            cost_test = W3*func_HEV_running_cost(motor_torque,tor_demand,rpm,HEV)+W2*(next_x-x_target)^2 + J_;
                            u_min_cost(k) = cost_test;
                        else
                            continue
                        end
                    else
                        continue
                    end
                end
                
                cost = min(u_min_cost);
            end
            J_F(j,length(v_sequence)-i-1) =cost ;
        
        end
        J_fc=griddedInterpolant(xi,J_F(:,length(v_sequence)-i-1));
    end
    
    % DP forward find the best strategy
    
    x_f = x_initial;
    x_ls = zeros(1,length(v_sequence));
    x_ls(1) = x_initial;
    for i = 1:length(v_sequence)-1
        
        tor_demand_f = tor_req(i);
        rpm_f = rpm_sequence(i);
        J_fc = griddedInterpolant(xi,J_F(:,i));
        if tor_demand_f <0
            optimal_action = func_HEV_control_regen(x_f,tor_demand_f,rpm_f,HEV);
            next_x = func_HEV_system_dynamics(x_f,optimal_action,tor_demand_f,rpm_f,HEV);
            % J_ = J_fc(next_x);
            cost_loop = W3*func_HEV_running_cost(optimal_action,tor_demand_f,rpm_f,HEV)+W2*(next_x-x_target)^2 ;
    
        else
            cost_test_ls = 10000*ones(1,length(u_list));
            for j = 1:length(u_list)
        
                if u_list(j)<tor_demand_f
                    tor_mot =u_list(j);
                    %[~,~,input_is_valid] = func_HEV_input_constraint_satisfied(tor_mot,tor_demand_f,rpm_f,HEV);
                    next_x = func_HEV_system_dynamics(x_f,tor_mot,tor_demand_f,rpm_f,HEV);
                    next_x_is_valid = func_HEV_soc_constraint_satisfied(next_x,HEV);
    
    
        
                    if next_x_is_valid == true
                        J_ = J_fc(next_x);
                        cost_test = W3*func_HEV_running_cost(tor_mot,tor_demand_f,rpm_f,HEV)+W2*(next_x-x_target)^2 + J_;
        
        
                    else
                        continue
                    end
    
    
                else
                    continue
                end
                cost_test_ls(j) = cost_test;
                
                
            end
            [~,state] = min(cost_test_ls);
            optimal_action = u_list(state);
            next_x = func_HEV_system_dynamics(x_f,optimal_action,tor_demand_f,rpm_f,HEV);
            % J_ = J_fc(next_x);
            cost_loop = W3*func_HEV_running_cost(optimal_action,tor_demand_f,rpm_f,HEV)+W2*(next_x-x_target)^2 ;
        end
        cost_ls(i) = cost_loop;
        x_f = next_x;
        x_ls(i+1) = x_f;
        action_ls(i) = optimal_action;
    end
    x_end = x_ls(end);
    cost_Terminal = W1*(x_initial-x_end)^2;
    cost_ls = [cost_ls,cost_Terminal];
    cost_total = sum(cost_ls);
    ls = [x_ls;0,action_ls];
end

