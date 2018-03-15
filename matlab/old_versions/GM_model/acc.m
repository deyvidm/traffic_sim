function a = acc(l_prev_speed, f_prev_speed, tau)
    
    a = (1/tau) * (l_prev_speed - f_prev_speed);

end
