total_time = 20;
reaction_time = 1;
granularity = 0.5;
l = 1;
m = 0;
alpha = 13;

graphtype = "-"
reaction_ticks = reaction_time/granularity;
ticks = 0:granularity:total_time;
data = zeros(length(ticks),7);
data(1,:) = [0,0,16, 28, 0, 16, 0];
data(:,1) = ticks;
data(5:8,2) = 5;    % leader acceleration
data(9:12,2) = -5; % leader decceleration


for i = 2:length(ticks)
    
    prev_index = i- 1;
    reaction_index = i - reaction_ticks;
    if reaction_index < 1
        reaction_index = 1;
    end
    l_prev_acc = data(prev_index,2);
    l_prev_speed = data(prev_index,3);
    l_prev_pos = data(prev_index,4);

    f_prev_acc = data(prev_index,5);
    f_prev_speed = data(prev_index,6);
    f_prev_pos = data(prev_index,7);

    % properties at time of reaction
    % (they are delayed, so we need to look farther back)
    l_reaction_speed = data(reaction_index, 3);
    l_reaction_pos = data(reaction_index,4);
    f_reaction_speed = data(reaction_index,6);
    f_reaction_pos = data(reaction_index,7);
    
    l_curr_acc = data(i,2);
    l_curr_speed = speed(l_prev_acc, l_prev_speed, ticks(i) - ticks(i-1));
    l_curr_pos = position(l_prev_acc, l_prev_pos, l_prev_speed, ticks(i) - ticks(i-1));

    f_curr_speed = speed(f_prev_acc, f_prev_speed, ticks(i) - ticks(i-1));
    f_curr_pos = position(f_prev_acc, f_prev_pos, f_prev_speed, ticks(i) - ticks(i-1));
    t =  tau(l, m, alpha, f_curr_speed, l_reaction_pos, f_reaction_pos);
    f_curr_acc = acc(l_reaction_speed, f_reaction_speed, t);

    data(i,:) = [ticks(i), l_curr_acc, l_curr_speed, l_curr_pos, f_curr_acc, f_curr_speed, f_curr_pos];
    
end

colNames = {'time','l_acc','l_speed','l_pos','f_acc','f_speed', 'f_pos'};
sTable = array2table(data,'RowNames', {},'VariableNames',colNames)

file = fopen(strcat(getenv('HOME'), '/school/research/visualization/data.json'), 'w');
fprintf(file, jsonencode(data'));

return

table_velocity_time = subplot(3,1,1);
plot(table_velocity_time, data(:,1),data(:,6),strcat('g',graphtype),'LineWidth',2);
hold on
plot(table_velocity_time, data(:,1),data(:,3),strcat('r',graphtype),'LineWidth',2);
ylabel(table_velocity_time, "velocity");
xlabel(table_velocity_time, "time");
legend(table_velocity_time,"follower", "red leader");
hold off

table_acc_time = subplot(3,1,2);
plot(table_acc_time, data(:,1),data(:,5),strcat('g',graphtype),'LineWidth',2);
hold on
plot(table_acc_time, data(:,1),data(:,2),strcat('r',graphtype),'LineWidth',2);
ylabel(table_acc_time, "acceleration");
xlabel(table_acc_time, "time");
legend(table_acc_time, "follower", "red leader");   
hold off

table_pos_time = subplot(3,1,3);
plot(table_pos_time, data(:,1),data(:,4)-data(:,7),strcat('g',graphtype),'LineWidth',1);
ylabel(table_pos_time, "position");
xlabel(table_pos_time, "time");
hold off
% pitts(uf, ul)
% next_position(acc, prev_pos, prev_speed, time_diff)
% next_acc(prev_speed, speed, time_diff)
% speed(pos, prev_acc, prev_speed, prev_pos)


