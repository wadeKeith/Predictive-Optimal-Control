function motor_torque = func_HEV_control_regen(soc,torque_demand,rpm,HEV) % only called when torque_demand < 0
    
    if torque_demand >= 0
        error('positive torque_demand at regeneration')
    else
        motor_torque = 0.5*torque_demand; % regen 50%
        if motor_torque < -200
            motor_torque = -200;
        end
        next_soc_is_valid = func_HEV_next_soc_constraint_satisfied(soc,motor_torque,torque_demand,rpm,HEV);
        if next_soc_is_valid == false
            motor_torque = 0;
        end
    end
end