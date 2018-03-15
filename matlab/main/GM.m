classdef GM < handle
    
    properties
        l
        m
        alpha
        time_diff
        reaction_time
        
        leader
        follower
        ticks
        step_size
    end
    
    methods
        function obj = GM(l, m, alpha, time_diff, reaction_time)
            obj.l = l;
            obj.m = m;
            obj.alpha = alpha;
            obj.time_diff = time_diff;
            obj.reaction_time = reaction_time;
        end
        
        function set_time(self, end_time, step_size)
            self.ticks = Ticks(end_time, step_size, self.reaction_time);
            self.step_size = step_size;
        end
        
        function t = tau(self, curr_speed, l_prev_pos, prev_pos)
           t = (l_prev_pos - prev_pos)^self.l/(self.alpha * curr_speed^self.m); 
        end
        
        function s = speed(self, prev_acc, prev_speed, time_diff)
            if nargin < 3
                time_diff = 1;
            end 
            s = prev_speed + prev_acc * time_diff;
        end
        
        function n = position(self, prev_acc, prev_pos, prev_speed, time_diff)
            if nargin < 4
                time_diff = 1;
            end
            n = prev_pos + prev_speed*time_diff + 0.5 * prev_acc * time_diff^2;
        end
        
        function a = acc(self, l_prev_speed, prev_speed, tau)
            a = (1/tau) * (l_prev_speed - prev_speed);
        end

        function start_following(self, leader)
            self.leader = leader;
            leader.follower = self;
        end
        
        function perform_tick(self)
            self.ticks.advance_tick();
            
            previous_data = self.ticks.get_prev_tick();
            current_data = self.ticks.get_current_tick();
            acc = current_data.acc;
            
            speed = self.speed(         ...
                previous_data.acc,      ...
                previous_data.speed,    ...
                self.time_diff          ...
            );
            
            pos = self.position(        ...
                previous_data.acc,      ...
                previous_data.pos,      ...
                previous_data.speed,    ...
                self.time_diff          ...
            );

            if ~isempty(self.leader)
                reaction_data = self.ticks.get_reaction_tick();
                leader_reaction_data = self.leader.ticks.get_reaction_tick();
                tau =  self.tau( ...
                    speed, ...
                    leader_reaction_data.pos,       ...
                    reaction_data.pos               ...
                );
                acc = self.acc(                     ...
                    leader_reaction_data.speed,     ...
                    reaction_data.speed,            ...
                    tau                             ...
                );
            end

            data = Properties();
            data.pos = pos;
            data.speed = speed;
            data.acc = acc;
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

