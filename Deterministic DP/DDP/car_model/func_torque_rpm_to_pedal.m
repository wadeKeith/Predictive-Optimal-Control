
function pedal = func_torque_rpm_to_pedal(torque,rpm,HEV)
%     if rpm < 800
%         rpm = 800;
%     elseif rpm > 3500
%         rpm = 3500;
%     end

    test_table_pedal = [0;2;10;20;30;40;50;60;70;85;100];
    torque_at_pedal_grid = test_table_pedal*0;
    for i = 1:length(test_table_pedal)
        torque_at_pedal_grid(i) = HEV.engine_torque_2d(test_table_pedal(i),rpm);
    end
    pedal = interp1(torque_at_pedal_grid,test_table_pedal,torque,'spline');
    if pedal >= 100
        pedal = 100;
    elseif pedal < 0
        pedal = 0;
    end
end