function n = next_position(acc, prev_pos, prev_speed, time_diff)
    if nargin < 4
        time_diff = 1;
    end
    n = prev_pos + prev_speed*time_diff + 0.5 * acc * time_diff^2;
end