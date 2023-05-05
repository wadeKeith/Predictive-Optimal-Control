

function engine_torque = func_HEV_compute_engine_torque(motor_torque,torque_demand,HEV)
    
    if torque_demand >= 0
        if torque_demand - motor_torque >= 0
            engine_torque = torque_demand - motor_torque;
        else
            engine_torque = 0;
        end
    else 
        engine_torque = 0;
    end
end