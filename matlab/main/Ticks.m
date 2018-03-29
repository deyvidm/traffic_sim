classdef Ticks < handle
    
    properties
        ticks
        current_tick
        
        start_time
        step_size
        end_time
        reaction_time
    end
    
    methods
        function obj = Ticks(end_time, step_size, reaction_time)
            obj.ticks = containers.Map('KeyType', 'double', 'ValueType', 'any');
            for i =[0: step_size: end_time]
                obj.ticks(i) = Properties();
            end
            
            obj.current_tick = 0;
            obj.start_time = 0;
            obj.end_time = end_time;
            obj.step_size = step_size;
            obj.reaction_time = reaction_time;
        end
        
% ####### getters #######
        function r = get_time_tick(self, n)
            r = self.ticks(n);
        end
        
        function r = get_previous_n_ticks(self, n)
            r = [];
            prev_ticks = (self.current_tick - n*self.step_size:...
                            self.step_size:...
                            self.current_tick - self.step_size);
            for t=prev_ticks
                if t < self.start_time
                    continue;
                end
                
                if isempty(r)
                    r = self.ticks(t);
                else
                    r = [r, self.ticks(t)];
                end
            end
        end
        function r = get_prev_tick(self)
            r = self.get_time_tick(self.current_tick - self.step_size);
        end

        function r = get_current_tick(self)
            r = self.get_time_tick(self.current_tick);
        end

        function r = get_reaction_tick(self)
            reaction_tick_index = self.current_tick - self.reaction_time;

            if reaction_tick_index < self.start_time
                reaction_tick_index = self.start_time;
            end

            r = self.get_time_tick(reaction_tick_index);
        end

% ####### setters #######
        function update_tick_data(self, data, tick_number)
            if nargin < 3
                tick_number = self.current_tick;
            end
            tick = self.ticks(tick_number);
            tick.update(data); 
            
        end
        
        function fill_tick_data(self, data, start_tick, end_tick)
            if start_tick < self.start_time
                error("starting time is out of range");
            elseif end_tick > self.end_time
                error("ending time is out of range");
            end
            
            for i = [start_tick:self.step_size:end_tick]
                self.update_tick_data(data, i);
            end
        end
        
% ####### utility #######        
        function advance_tick(self)
            self.current_tick = self.current_tick + self.step_size;
            if self.current_tick > self.end_time
                error('exceeded time');
            end
        end
        
        function p = summary(self)
            p = containers.Map;
            p('acc') = [];
            p('speed') = [];
            p('pos') = [];
            p('lane') = [];
            
            for key = keys(self.ticks)
                i = key{1};
                p('acc') =   [ p('acc'), self.ticks(i).acc ];
                p('speed') = [ p('speed'), self.ticks(i).speed ];
                p('pos') =   [ p('pos'), self.ticks(i).pos ];
                p('lane') = [ p('lane'), self.ticks(i).lane ];
            end
        end
        
        function print_summary(self)
            summary = self.summary();
            data = [
                self.time()',        ...
                summary('acc')',     ...
                summary('speed')',   ...
                summary('pos')',     ...
                summary('lane')'     ...
            ];
        
            colNames = {'time','acc','speed','pos', 'lane'};
            array2table(data,'RowNames', {},'VariableNames',colNames)
        end
        
        function r = time(self)
            r = [0:self.step_size:self.end_time];
        end
    end
end

