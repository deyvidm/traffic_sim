function s = speed(pos, prev_acc, prev_speed, prev_pos)
%     pos
%     prev_acc
%     prev_speed
%     prev_pos
    s = sqrt(prev_speed^2 + 2 * prev_acc * (pos - prev_pos));
end