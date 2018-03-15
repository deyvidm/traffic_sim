classdef Gipps < handle
    
    properties
        size
        max_acc
        max_decc
        perceived_max_decc
        target_speed
        reaction_time
        preferred_spacing
        time_diff
        
        leader
        follower
        ticks
        step_size
    end
    
    methods
        function obj = Gipps(size, max_acc, max_decc, perceived_max_decc, target_speed, preferred_spacing, reaction_time, time_diff)
            obj.size = size;
            obj.max_acc = max_acc;
            obj.max_decc = max_decc;
            obj.perceived_max_decc = perceived_max_decc;
            obj.target_speed = target_speed;
            obj.preferred_spacing = preferred_spacing;
            obj.time_diff = time_diff;
            
            obj.reaction_time = reaction_time;
        end
        
        function set_time(self, end_time, step_size)
            self.ticks = Ticks(end_time, step_size, self.reaction_time);
            self.step_size = step_size;
        end

        function s = speed(self, prev_speed, l_prev_pos, l_prev_speed, prev_pos)
%             s = min([
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
                            l_prev_pos - self.leader.size - self.preferred_spacing  - prev_pos        ...
                        )                                                   ...
                        - prev_speed * self.reaction_time - (               ...
                            l_prev_speed^2/self.leader.perceived_max_decc   ...
                        )                                                   ...
                    )                                                       ...
                 )                                                          ...
                 ]
              s = min(d);
              d
%              ]);
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

        function start_following(self, leader)
            self.leader = leader;
            leader.follower = self;
        end
        
        function perform_tick(self)
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

            data = Properties();
            data.pos = pos;
            data.speed = speed;
            data.acc = acc;
            data.lane = current_data.lane;
            self.ticks.update_tick_data(data)

            if ~isempty(self.follower)
                self.follower.perform_tick()
            end
        end
        
        
        function perform_all_ticks(self)
            time = self.ticks.time();
            for i = time(1:end-1)
                self.perform_tick() 
            end
        end
        
    end
end

