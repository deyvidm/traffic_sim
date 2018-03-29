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
        
        ticks_window_for_avg_speed
        new_follower;
        new_follower_countdown;
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
            obj.ticks_window_for_avg_speed = 5;
            
%           used for keeping track of when (and who) will follow this car 
%           after a lane change
            obj.new_follower = [];
            obj.new_follower_countdown = -1;
        end
        
        function set_time(self, end_time, step_size)
            self.ticks = Ticks(end_time, step_size, self.reaction_time);
            self.step_size = step_size;
        end

%       methods that define/change state
%       i.e. the meat of the models

%       car-following models and state
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
            
%       lane-changing models and state
        function r = need_to_change_lane(self)
            r = 0;
            
% --------- remove me
            props = self.ticks.get_current_tick();
            if props.lane > 1
                return
            end
% --------- remove me
            
            v = self.get_avg_speed();
            p = exp(-(v/self.target_speed)^2);
            r = p;
        end
        
        function l = able_to_change_lane(self)
            l = 1;
        end
        

%       utility regarding state/models
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
        
        function l = change_lane_left(self)
            l = self.road.change_lane_left(self);
        end
        
        function l = change_lane_right(self)
            l = self.road.change_lane_right(self);
        end
        
        function set_lane(self, lane)
            data = Properties();
            data.lane = lane;
            self.ticks.update_tick_data(data);
        end
        
        function swap_lane_change_roles(self, lane, pos)
            [back, front] = self.road.get_spread_at_pos(lane, pos);
%               this is a problem if there is no new leader -- need to fix
%               this
            if ~isempty(self.leader) && ~isempty(self.followers)
                for f = self.followers
                    f.start_following(self.leader);
                end
%                 self.leader.follower = self.follower;
            end
%             if ~isempty(self.follower)
%                 self.follower.leader = self.leader;
%             end
            self.start_following(front);
%             self.leader = front;
            self.new_follower = back;
            self.new_follower_countdown = 2;
        end
        
%       procedural
        function perform_properties_tick(self)
            disp(strcat("from tick ----- ", self.name))
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
            if self.new_follower_countdown == 0
                self.new_follower.start_following(self);
                self.new_follower_countdown = -1;
            end
    
            props = self.ticks.get_current_tick();
            lane = props.lane;
            
            if ~isempty(self.leader) && self.need_to_change_lane() && self.able_to_change_lane()
                lane = self.change_lane_left();
                if lane
                    self.swap_lane_change_roles(lane, props.pos)
                else
                    lane = previous_data.lane;
                end
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

