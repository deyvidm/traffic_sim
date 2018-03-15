size = 6.5;
max_acc = 2;
max_decc = -3;
perceived_max_decc = -3.5;
target_speed = 20;
preferred_spacing = 0;
reaction_time = 2/3;

% reaction time NEEDS to be < the tick interval
end_time = 40;
step = 1;

% the time diff for this model needs to be the step size
time_diff = step;

leader = Gipps(size, max_acc, max_decc, perceived_max_decc, target_speed, preferred_spacing, reaction_time, time_diff);
leader.set_time(end_time, step);

follower = Gipps(size, max_acc, max_decc, perceived_max_decc, target_speed, preferred_spacing, reaction_time, time_diff);
follower.set_time(end_time, step);
follower.start_following(leader);

% leader inits
data = Properties();
data.speed = 0;
data.acc = 0;
data.pos = 13.9;
leader.ticks.update_tick_data(data, 0);

data = Properties();
data.speed = 50;
leader.ticks.update_tick_data(data, 1);

data = Properties();
data.speed = 53;
leader.ticks.update_tick_data(data, 2);

data = Properties();
data.speed = 53.5;
leader.ticks.update_tick_data(data, 3);

data = Properties();
data.speed = 55;
leader.ticks.update_tick_data(data, 4);

% follower init
data = Properties();
data.speed = 4;
follower.ticks.update_tick_data(data, 0);

data = Properties();
data.lane = 2;
follower.ticks.fill_tick_data(data, 5, leader.ticks.end_time);

data = Properties();
data.speed = 4.02;
follower.ticks.update_tick_data(data, 0);

% wrap up
leader.perform_all_ticks();
leader.ticks.print_summary();
follower.ticks.print_summary();

data = containers.Map;
data('time') = leader.ticks.time();
data('follower') = follower.ticks.summary();
data('leader') = leader.ticks.summary();

file = fopen(strcat(getenv('HOME'), '/school/research/visualization/data/data.json'), 'w');
fprintf(file, jsonencode(data'));

% summary = leader.ticks.summary();
% data = [leader.ticks.time(); summary = ];
% % colNames = {'time','l_acc','l_speed','l_pos','f_acc','f_speed', 'f_pos'};
% colNames = {'time','l_acc','l_speed','l_pos'};
% sTable = array2table(data,'RowNames', {},'VariableNames',colNames)
