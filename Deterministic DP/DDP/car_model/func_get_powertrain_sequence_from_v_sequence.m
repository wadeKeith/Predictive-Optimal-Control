

function [torque_sequence, rpm_sequence, gear_sequence] = func_get_powertrain_sequence_from_v_sequence(v_sequence,grade_sequence,HEV) % 1Hz data
    torque_sequence = v_sequence*0;
    rpm_sequence = v_sequence*0;
    gear_sequence = v_sequence*0;
    gear_sequence(1) = get_gear(v_sequence(1));
    for i = 1:length(v_sequence)
        gear = gear_sequence(i);
        v = v_sequence(i);
        acc = get_acc_from_v_s(v_sequence,i);
        grade = grade_sequence(i);
        [trans_in_torque,rpm] = transmission_input_from_vag(v,acc,grade,gear,HEV);
        %pedal = func_torque_rpm_to_pedal(trans_in_torque,rpm,HEV);
        if i < length(v_sequence)
            new_gear = get_gear(v_sequence(i+1));
            gear_sequence(i+1) = new_gear;
        end
        
        torque_sequence(i) = trans_in_torque;
        rpm_sequence(i) = rpm;
        
    end
end


function [trans_in_torque,trans_in_rpm] = transmission_input_from_vag(v,acc,grade,gear,HEV)
    if v > 0
        f_road = HEV.f_tire*HEV.G;
    else
        f_road = 0;
    end
    f_air = 0.5*HEV.Cd*HEV.A*v*v;
    f_grade = grade*HEV.G;
    f_acc = HEV.delta_inertial(gear)*HEV.m*acc;
    
    force = f_road + f_air + f_grade + f_acc;
    
    trans_in_torque =  force*HEV.r_tire/HEV.Axle_ratio/HEV.Gear_ratio(gear)/0.98;
    trans_in_rpm = v/HEV.r_tire/2/pi*60*HEV.Axle_ratio*HEV.Gear_ratio(gear);
%     if trans_in_rpm/trans_in_torque <4.55
%         trans_in_torque = trans_in_rpm/4.55;
%     end

end


function gear = get_gear(v)
   
    if v < 3
        gear = 1;
    elseif v>=3 && v<10
        gear = 2;
    elseif v>=10 && v<20
        gear = 3;
    elseif v>=20 && v<30
        gear = 4;
    elseif v>=30 && v<40
        gear = 5;
    else
        gear = 6;
    end
end



function acc = get_acc_from_v_s(v_sequence,i)
    time = 0.1; % 1s
    if i < length(v_sequence)
        v = v_sequence(i);
        v_plus = v_sequence(i+1);
        acc = (v_plus-v)/time;
    else
        acc = 0.1;
    end
end



    
    
    
    
    
    