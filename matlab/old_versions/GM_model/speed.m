function s = speed(prev_acc, prev_speed, time_diff)
    if nargin < 3
        time_diff = 1;
    end 
    s = prev_speed + prev_acc * time_diff;
end