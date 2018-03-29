size = 6.5;
max_acc = 2;
max_decc = -3;
perceived_max_decc = -3.5;
target_speed = 20;
preferred_spacing = 0;
reaction_time = 2/3;

% reaction time combines with an unspecified theta to form the step size
% if reaction time == 2/3  then theta is 1/3, making the step size 1
end_time = 40;
step = 1;

% the time diff for this model needs to be the step size
time_diff = step;

leader_1 = Gipps('leader_1', size, max_acc, max_decc, perceived_max_decc, target_speed, ...
    preferred_spacing, reaction_time, time_diff ...
);
leader_1.set_time(end_time, step);

follower_1 = Gipps('follower_1', size, max_acc, max_decc, perceived_max_decc, target_speed, ...
    preferred_spacing, reaction_time, time_diff ...
);
follower_1.set_time(end_time, step);
follower_1.start_following(leader_1);


leader_2 = Gipps('leader_2', size, max_acc, max_decc, perceived_max_decc, target_speed, ...
    preferred_spacing, reaction_time, time_diff ...
);
leader_2.set_time(end_time, step);

follower_2 = Gipps('follower_2', size, max_acc, max_decc, perceived_max_decc, target_speed, ...
    preferred_spacing, reaction_time, time_diff ...
);
follower_2.set_time(end_time, step);
follower_2.start_following(leader_2);

% leader inits
data = Properties();
data.speed = 10;
data.acc = 0;
data.pos = 40;
data.lane = 1;
leader_1.ticks.fill_tick_data(data, 0, end_time);

data = Properties();
data.speed = 10;
data.acc = 0;
data.pos = 40;
data.lane = 2;
leader_2.ticks.fill_tick_data(data, 0, end_time);

% follower init
data = Properties();
data.speed = 10;
data.acc = 0;   
data.pos = 20;
data.lane = 1;
follower_1.ticks.update_tick_data(data, 0);

data = Properties();
data.speed = 10;
data.acc = 0;   
data.pos = 15;
data.lane = 2;
follower_2.ticks.update_tick_data(data, 0);

% wrap up
road = Road(2, leader_1);
road.add_to_road(leader_1, 1);
road.add_to_road(follower_1, 1);
road.add_to_road(leader_2, 2);
road.add_to_road(follower_2, 2);

% start
% road.perform_n_ticks(end_time);
road.perform_n_ticks(40);
% leader_1.ticks.print_summary();
% follower_1.ticks.print_summary();

data = containers.Map;
data('time') = leader_1.ticks.time();
data('follower_1') = follower_1.ticks.summary();
data('leader_1') = leader_1.ticks.summary();
data('follower_2') = follower_2.ticks.summary();
data('leader_2') = leader_2.ticks.summary();

file = fopen(strcat(getenv('HOME'), '/school/research/visualization/data/data.json'), 'w');
fprintf(file, jsonencode(data'));
