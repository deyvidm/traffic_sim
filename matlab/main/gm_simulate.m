
leader = GM(1, 0, 13, 0.5, 1);
leader.set_time(20, 0.5)

follower = GM(1, 0, 13, 0.5, 1);
follower.set_time(20, 0.5)
follower.start_following(leader);

follower_2 = GM(1, 0, 13, 0.5, 1);
follower_2.set_time(20, 0.5)
follower_2.start_following(follower);

data = Properties();
data.speed = 20;
data.pos = 0;
follower_2.ticks.update_tick_data(data, 0)

data = Properties();
data.speed = 16;
data.pos = 30;
follower.ticks.update_tick_data(data, 0)

data = Properties();
data.acc = 0;
data.pos = 60;
data.speed = 16;
leader.ticks.update_tick_data(data, 0)

data = Properties();
data.acc = 5;
leader.ticks.update_tick_data(data, 2.0)
leader.ticks.update_tick_data(data, 2.5)
leader.ticks.update_tick_data(data, 3.0)
leader.ticks.update_tick_data(data, 3.5)

data = Properties();
data.acc = -5;
leader.ticks.update_tick_data(data, 4.0)
leader.ticks.update_tick_data(data, 4.5)
leader.ticks.update_tick_data(data, 5.0)
leader.ticks.update_tick_data(data, 5.5)

leader.perform_all_ticks()

data = containers.Map;
data('time') = leader.ticks.time();
data('follower_2') = follower_2.ticks.summary();
data('follower') = follower.ticks.summary();
data('leader') = leader.ticks.summary();

file = fopen(strcat(getenv('HOME'), '/school/research/visualization/data/data.json'), 'w');
fprintf(file, jsonencode(data'));