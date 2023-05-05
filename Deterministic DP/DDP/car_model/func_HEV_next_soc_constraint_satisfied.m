function next_soc_is_valid = func_HEV_next_soc_constraint_satisfied(soc,motor_torque,torque_demand,rpm,HEV)
    
    next_soc = func_HEV_system_dynamics(soc,motor_torque,torque_demand,rpm,HEV);
    
    next_soc_is_valid = func_HEV_soc_constraint_satisfied(next_soc,HEV);
    
end