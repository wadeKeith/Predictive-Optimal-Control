
function soc_is_valid = func_HEV_soc_constraint_satisfied(soc,HEV)
    if soc >= 0.2 && soc <= 0.8
        soc_is_valid = true;
    else
        soc_is_valid = false;
    end
end