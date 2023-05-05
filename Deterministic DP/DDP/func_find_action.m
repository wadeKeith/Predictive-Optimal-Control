function [optimal_action] = func_find_action(x_initial,v_sequence,grade_sequence,x_target,W1,W2,W3,HEV)
    %data processing
    
    %some constant
    xi=linspace(0.2,0.8,61);
    u_list = linspace(-200,200,401);
    %DP programming
    [tor_req,rpm_sequence,~] = func_get_powertrain_sequence_from_v_sequence(v_sequence,grade_sequence,HEV);
    J_F = 100000*ones(length(xi),length(v_sequence)-1);

    
    % DP backward find the best cost
    for p = 1:length(xi)
        J_F(p,end) = W1*(x_initial-xi(p))^2;
    end
    J_fc=griddedInterpolant(xi,J_F(:,end));

    for i = 1:length(v_sequence)-2
        tor_demand = tor_req(length(v_sequence)-i);
        rpm = rpm_sequence(length(v_sequence)-i);
        for j = 1:length(xi)
            if tor_demand < 0
                motor_torque = func_HEV_control_regen(xi(j),tor_demand,rpm,HEV);
                [~,~,input_is_valid] = func_HEV_input_constraint_satisfied(motor_torque,tor_demand,rpm,HEV);
                next_x = func_HEV_system_dynamics(xi(j),motor_torque,tor_demand,rpm,HEV);
                next_x_is_valid = func_HEV_soc_constraint_satisfied(next_x,HEV);
                if next_x_is_valid == true && input_is_valid == true
                    J_ = J_fc(next_x);
                    cost = W3*func_HEV_running_cost(motor_torque,tor_demand,rpm,HEV)+W2*(next_x -x_target)^2 + J_;
                else
                    J_ = J_fc(0.8);
                    cost = W3*func_HEV_running_cost(motor_torque,tor_demand,rpm,HEV)+W2*(0.8 -x_target)^2 + J_;
                end
            else
                u_min_cost = 1e8*ones(1,length(u_list));
                for k = 1:length(u_list)
                    if u_list(k)<tor_demand
                        motor_torque = u_list(k);
                        [~,~,input_is_valid] = func_HEV_input_constraint_satisfied(motor_torque,tor_demand,rpm,HEV);
                        next_x = func_HEV_system_dynamics(xi(j),motor_torque,tor_demand,rpm,HEV);
                        next_x_is_valid = func_HEV_soc_constraint_satisfied(next_x,HEV);
        
                        if  next_x_is_valid == true && input_is_valid == true
                            J_ = J_fc(next_x);
                            cost_test = W3*func_HEV_running_cost(motor_torque,tor_demand,rpm,HEV)+W2*(next_x -x_target)^2 + J_;
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
    tor_demand_f = tor_req(1);
    rpm_f = rpm_sequence(1);
    J_fc = griddedInterpolant(xi,J_F(:,1));
    if tor_demand_f <0
        optimal_action = func_HEV_control_regen(x_f,tor_demand_f,rpm_f,HEV);

    else
        cost_test_ls = 10000*ones(1,length(u_list));
        for j = 1:length(u_list)
    
            if u_list(j)<tor_demand_f
                tor_mot =u_list(j);
                [~,~,input_is_valid] = func_HEV_input_constraint_satisfied(tor_mot,tor_demand_f,rpm_f,HEV);
                next_x = func_HEV_system_dynamics(x_f,tor_mot,tor_demand_f,rpm_f,HEV);
                next_x_is_valid = func_HEV_soc_constraint_satisfied(next_x,HEV);


    
                if  next_x_is_valid == true && input_is_valid == true
                    J_ = J_fc(next_x);
                    cost_test = W3*func_HEV_running_cost(tor_mot,tor_demand_f,rpm_f,HEV)+W2*(next_x -x_target)^2 + J_;
    
    
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
    end
end
    

