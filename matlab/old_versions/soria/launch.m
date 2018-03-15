ticks = 5;
data = zeros(ticks,7);
data(1,:) = [0,4.4,1300.9, 1, 4, 0, 1300.9];
data(2,2) = 4.2;
data(3,2) = 3.8;
data(4,2) = 3.6;
data(5,2) = 4.2;

for i = 2:ticks
    
    l_prev_acc = data(i-1,1);
    l_prev_speed = data(i-1,2);
    l_prev_pos = data(i-1,3);
    
    f_prev_acc = data(i-1,4);
    f_prev_speed = data(i-1,5);
    f_prev_pos = data(i-1,6);
    
    l_curr_speed = data(i,2);
    l_curr_acc = next_acc(l_prev_speed, l_curr_speed);
    l_curr_pos = next_position(l_curr_acc, l_prev_pos, l_prev_speed);
      
    spacing = pitts(f_prev_speed, l_prev_speed);
    f_curr_pos = l_curr_pos - spacing;
    f_curr_speed = speed(f_curr_pos, f_prev_acc, f_prev_speed, f_prev_pos);
    f_curr_acc = next_acc(f_prev_speed, f_curr_speed);
    
    data(i,:) = [l_curr_acc, l_curr_speed, l_curr_pos, f_curr_acc, f_curr_speed, f_curr_pos, spacing];
end

data

% pitts(uf, ul)
% next_position(acc, prev_pos, prev_speed, time_diff)
% next_acc(prev_speed, speed, time_diff)
% speed(pos, prev_acc, prev_speed, prev_pos)


