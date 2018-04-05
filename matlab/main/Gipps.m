classdef Gipps < handle
    
    properties
        name
        road
        size
        max_acc
        max_decc
        perceived_max_decc
        target_speed
        reaction_time
        preferred_spacing
        time_diff
        
        leader
        followers
        ticks
        step_size
        
        lane_change_speed_threshold
        ticks_window_for_avg_speed
        new_follower;
        new_follower_countdown;
        bayesian;
    end
    
    methods
        function obj = Gipps(name, size, max_acc, max_decc, perceived_max_decc, ...
                target_speed, preferred_spacing, reaction_time, time_diff)
            obj.name = name;
            obj.size = size;
            obj.max_acc = max_acc;
            obj.max_decc = max_decc;
            obj.perceived_max_decc = perceived_max_decc;
            obj.target_speed = target_speed;
            obj.preferred_spacing = preferred_spacing;
            obj.time_diff = time_diff;
            
            obj.reaction_time = reaction_time;
            obj.lane_change_speed_threshold = 0.9;
            obj.ticks_window_for_avg_speed = 5;
            
%           used for keeping track of when (and who) will follow this car 
%           after a lane change
            obj.new_follower = [];
            obj.new_follower_countdown = -1;
            obj.bayesian = BayesianInference(1,1);
        end
        
        function set_time(self, end_time, step_size)
            self.ticks = Ticks(end_time, step_size, self.reaction_time);
            self.step_size = step_size;
        end

%       methods that define/change state
%       i.e. the meat of the models

%%%%%%%% car-following models and state
        function s = speed(self, prev_speed, l_prev_pos, l_prev_speed, prev_pos)
              d = [
                prev_speed                                                  ...
                + 2.5 * self.max_acc * self.reaction_time                   ...
                * (1 - (prev_speed/self.target_speed))                      ...
                * sqrt(0.025 + (prev_speed/self.target_speed))

                self.max_decc * self.reaction_time                          ...
                + sqrt(                                                     ...
                    self.max_decc^2 * self.reaction_time^2                  ...
                    - self.max_decc*(                                       ...
                        2*(                                                 ...
                            l_prev_pos - self.leader.size - self.preferred_spacing  - prev_pos...
                        )                                                   ...
                        - prev_speed * self.reaction_time - (               ...
                            l_prev_speed^2/self.leader.perceived_max_decc   ...
                        )                                                   ...
                    )                                                       ...
                 )                                                          ...
              ];
              s = min(d);
        end
        
        function n = position(self, acc, prev_pos, prev_speed, time_diff)
            if nargin < 4
                time_diff = 1;
            end
            n = prev_pos + prev_speed*time_diff + 0.5 * acc * time_diff^2;
        end
        
        function a = acc(self, speed, prev_speed, time_diff)
            if nargin < 3
                time_diff = 1;
            end 
            if time_diff == 0
                error("can't div by 0")
            end
            a = (1/time_diff) * (speed - prev_speed);
        end
            
%%%%%%%% lane-changing models and state
        function r = need_to_change_lane(self, new_leader)
            r = 0;
            
            if isempty(self.leader) || isempty(new_leader)
                return
            end
            
%           don't change lanes if i'm traveling at X% of my target speed
            if self.get_avg_speed()/self.target_speed >= self.lane_change_speed_threshold
                return
            end
            
            new_leader_props = new_leader.ticks.get_current_tick();
            curr_leader_props = self.leader.ticks.get_current_tick();
            
            if new_leader_props.speed > curr_leader_props.speed
                r = 1;
            end
        end
        
        function l = able_to_change_lane(self, new_follower, new_leader)
            l = 1;
            if isempty(new_follower)
                return
            end
           
            
            props = self.get_current_props();
            new_follower_props = self.fuzzify(props, new_follower.get_current_props());
            
            back_spacing = props.pos - new_follower_props.pos - new_follower.size;
            if new_follower_props.speed * 2 > back_spacing
                l = 0;
            end
%             fprintf("\tspeed*2: %0.3f\tspacing: %0.3f\n", back_spacing, new_follower_props.speed*2);
            
            if isempty(new_leader)
                return
            end
            
            front_spacing = self.preferred_spacing + self.size;
            new_leader_props = self.fuzzify(props, new_leader.get_current_props());
            if (props.pos + props.speed * 2) - (new_leader_props.pos + new_leader_props.speed * 2) > front_spacing
                l = 0;
            end
            
        end
        
        function a = lane_change_approved(self, props)
            a = 0;
            
            if self.road.car_in_leftmost_lane(self) || self.new_follower_countdown >= 0
                return
            end
            
            lane = self.road.get_lane_left_of(props.lane);
            [back, front] = self.road.get_spread_at_pos(lane, props.pos);
            r = 0;

            if self.need_to_change_lane(front) && self.able_to_change_lane(back, front)
                r = 1;
            end
            [p,v] = self.bayesian.update(r);
            if self.name == "follower_1"
                fprintf("p=%0.5f\tv=%0.5f\ta=%d\tb=%d\tneed:%d\table: %d\n", p, v, self.bayesian.alpha, self.bayesian.beta,self.need_to_change_lane(front),self.able_to_change_lane(back, front));
            end
%           dipping p below 3 will cause mayhem with the models -- it'll
%           make the leader try to change lanes lol
            if p > 0.5 && v < 0.3
                a = 1;
            end
                
        end
        

%%%%%%% utility regarding state/models

        function target_props = fuzzify(self, own_props, target_props)
            space_diff = abs(own_props.pos - target_props.pos);
            std_dev = 1-exp(-space_diff) * 2;
            
            ret = target_props.clone();
            ret.speed = normrnd(target_props.speed, std_dev);
            ret.pos = normrnd(target_props.pos, std_dev);
            ret.acc = normrnd(target_props.acc, std_dev);
        end
    
        function s = get_avg_speed(self)
            speed_ticks = self.ticks.get_previous_n_ticks(self.ticks_window_for_avg_speed);
            total_speed = 0;
            for i=speed_ticks
                total_speed = i.speed + total_speed;
            end
            s = total_speed/self.ticks_window_for_avg_speed;
        end
        
        function start_following(self, leader)
            if ~isempty(self.leader) && ~isempty(self.leader.followers)
                self.leader.followers = self.leader.followers(self.leader.followers~=self);
            end
            self.leader = leader;
            if isempty(leader.followers)
                leader.followers = self;
            else
                leader.followers = [leader.followers, self];
            end
        end
        
        function p = get_current_props(self)
            p = self.ticks.get_current_tick();
        end
    
        function p = get_previous_props(self)
            p = self.ticks.get_prev_tick();
        end
        
        function set_lane(self, lane)
            data = Properties();
            data.lane = lane;
            self.ticks.update_tick_data(data);
        end
        
        function swap_lane_change_roles(self, back, front)
%           this is a problem if there is no new leader -- need to fix this
            if ~isempty(self.leader) && ~isempty(self.followers)
                for f = self.followers
                    f.start_following(self.leader);
                end
            end
            if ~isempty(front)
                self.start_following(front);
            end
            if ~isempty(back)
                self.new_follower = back;
                self.new_follower_countdown = 2;
            end
        end
        
%%%%%%% procedural
        function perform_properties_tick(self)
            self.ticks.advance_tick();
            
            previous_data = self.ticks.get_prev_tick();
            current_data = self.ticks.get_current_tick();
            speed = current_data.speed;
            
            if ~isempty(self.leader)
                leader_previous_data = self.leader.ticks.get_prev_tick();
                speed = self.speed(             ...
                    previous_data.speed,        ...
                    leader_previous_data.pos,   ...
                    leader_previous_data.speed, ...
                    previous_data.pos           ...
                );
            end
            
            acc = self.acc(                     ...
                speed,                          ...
                previous_data.speed,            ...
                self.time_diff                  ...
            );
            
            pos = self.position(        ...
                acc,                    ...
                previous_data.pos,      ...
                previous_data.speed,    ...
                self.time_diff          ...
            );
            
            lane = previous_data.lane;
        
            data = Properties();
            data.pos = pos;
            data.speed = speed;
            data.acc = acc;
            data.lane = lane;
           
            self.ticks.update_tick_data(data);
            
            if ~isempty(self.followers)
                for f = self.followers
                    f.perform_properties_tick();
                end
            end
        end
        
        function perform_role_tick(self)
            
            if self.new_follower_countdown > 0
                self.new_follower_countdown = self.new_follower_countdown - 1;
            end
            if self.new_follower_countdown == 0 && ~isempty(self.new_follower)
                self.new_follower.start_following(self);
                self.new_follower_countdown = -1;
            end
    
            props = self.ticks.get_current_tick();
            lane = props.lane;
                
            if self.lane_change_approved(props)
                [lane, back, front] = self.road.change_lane_left(self);
                self.swap_lane_change_roles(back, front)
            end
            
            data = Properties();
            data.lane = lane;
            self.ticks.update_tick_data(data);
                        
            if ~isempty(self.followers)
                for f = self.followers
                    f.perform_role_tick();
                end
            end
        end
        
        function perform_tick(self)
            self.perform_properties_tick();
            self.perform_role_tick();
        end
        
        function perform_all_ticks(self)
            time = self.ticks.time();
            for i = time(1:end-1)
                self.perform_tick();
            end
        end
        
    end
end

