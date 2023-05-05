

function next_soc = func_HEV_system_dynamics(soc,motor_torque,torque_demand,rpm,HEV)
    
    if motor_torque > 0
        bat_eff = HEV.battery_eff_dis_1d(soc);
        bat_power = - 1/bat_eff * motor_torque * rpm * 2*pi/60;
    else
        bat_eff = HEV.battery_eff_cha_1d(soc);
        bat_power = - bat_eff * motor_torque * rpm * 2*pi/60;
    end
    
    dt = 0.1; % 1s
    next_soc = soc + bat_power*dt/HEV.bat_q;
    
end
    
   
    
    