function fuel_consumption = func_HEV_running_cost(motor_torque,torque_demand,rpm,HEV)

    engine_torque = func_HEV_compute_engine_torque(motor_torque,torque_demand,HEV);
    
    fc_rate = get_fuel_consumption_rate(engine_torque,rpm,HEV);
    
    dt = 0.1; % 1s
    fuel_consumption = fc_rate*dt;
    
end


function fc_rate = get_fuel_consumption_rate(engine_torque,rpm,HEV)
    if engine_torque <= 0 || rpm < 0
        fc_rate = HEV.idle_fc_rate;
    else
        if rpm < 800
            rpm = 800;
        end
        fc_rate = HEV.engine_t_fc_2d(engine_torque,rpm);
    end
end