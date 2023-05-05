function [motor_torque_is_valid,engine_torque_is_valid,input_is_valid ]= func_HEV_input_constraint_satisfied(motor_torque,torque_demand,rpm,HEV) % note: did not check whether next_soc is valid here!
    
    motor_torque_is_valid = func_HEV_motor_torque_constraint_satisfied(motor_torque);
    engine_torque_is_valid = func_HEV_engine_torque_constraint_satisfied(motor_torque,torque_demand,rpm,HEV);
    
    if motor_torque_is_valid == true && engine_torque_is_valid == true
        input_is_valid = true;
    else
        input_is_valid = false;
    end
end


function motor_torque_is_valid = func_HEV_motor_torque_constraint_satisfied(motor_torque)
    if motor_torque >= -200 && motor_torque <= 200
        motor_torque_is_valid = true;
    else
        motor_torque_is_valid = false;
    end
end


function engine_torque_is_valid = func_HEV_engine_torque_constraint_satisfied(motor_torque,torque_demand,rpm,HEV)
    
    engine_torque = func_HEV_compute_engine_torque(motor_torque,torque_demand,HEV);
    
    engine_rpm = rpm;
    if engine_rpm < 800
        engine_rpm = 800;
    end
    
    max_engine_torque = HEV.max_engine_torque_1d(engine_rpm);
    
    if engine_torque > max_engine_torque || engine_torque>385.695472040000
        engine_torque_is_valid = false;
    else
        engine_torque_is_valid = true;
    end
    
end


