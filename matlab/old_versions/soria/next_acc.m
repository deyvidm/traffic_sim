function a = next_acc(prev_speed, speed, time_diff)
    if nargin < 3
        time_diff = 1;
    end
    
    a = (speed - prev_speed)/time_diff;
    
end