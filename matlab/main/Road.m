classdef Road < handle
    properties
        % for lanes, the higher the number, the further to the left 
        % example: 3-lane road going in only 1 direction
        % lane 3 == leftmost lane
        % lane 2 == middle lane
        % lane 1 == rightmost lane
        
        % illustration: 
        % =======[ A ]=========>    Lane 3
        % =======[ B ]=========>    Lane 2
        % =======[ C ]=========>    Lane 1
        lanes = containers.Map('KeyType', 'double', 'ValueType', 'any');
        leaders 
    end
    
    methods
        function obj = Road(lane_count, sample_model)
%           This will make sure that Road works with only one type of Car
%           model. This WILL NEED refactoring if we want to make it work
%           with multiple types of models.
            meta = metaclass(sample_model);
            for i=1:lane_count
%               Assumes max 10 cars/lane
                obj.lanes(i) = eval(strcat(meta.Name, '.empty(10, 0)'));
%               Assumes max 10 leaders on the road  
                obj.leaders = eval(strcat(meta.Name, '.empty(10, 0)'));
            end
        end
        
%%%%%%% change state (move cars from lanes, add cars, remove cars)
        function add_to_road(self, car, lane)
            car.road = self;
            
            if ismember(car, self.lanes(lane))
                error('car already added to lane');
            end
            
            if isempty(self.lanes(lane))
                self.lanes(lane) = car;
            else
                self.lanes(lane) = [self.lanes(lane), car];
            end
            
            car.set_lane(lane);
        end
        
         function add_car_to_lane(self, car, lane_number)
            lane = self.lanes(lane_number);
            if isempty(lane)
                lane = car;
            else
                lane = [lane, car];
            end
            self.lanes(lane_number) = lane;
         end
        
        function remove_car_from_lane(self, car, lane_number)
            lane = self.lanes(lane_number);
            lane = lane(lane~=car);
            self.lanes(lane_number) = lane;
        end
        
        function [new_lane, back, front] = change_lane_left(self, car)
            props = car.get_current_props();
            new_lane = self.get_lane_left_of(props.lane);
            [back, front] = self.get_spread_at_pos(new_lane, props.pos);
            
            self.remove_car_from_lane(car, props.lane)
            self.add_car_to_lane(car, new_lane)
        end
    
%%%%%%% evaluate state (getters)        
        function [behind, infront] = get_spread_at_pos(self, lane, pos)
            behind = [];
            infront = [];
            cars = self.lanes(lane);       
            
            for i=1:length(cars)
                car = cars(i);
                props = car.get_current_props();

                if props.pos >= pos
                    if isempty(infront)
                        infront = car;
                        continue
                    end
                    front_props = infront.get_current_props();
                    if props.pos < front_props.pos
                        infront = car;
                    end
                end
                
                if props.pos < pos
                    if isempty(behind)
                        behind = car;
                        continue
                    end
                    behind_props = behind.get_current_props();
                    if props.pos > behind_props.pos 
                        behind = car;
                    end
                end
            end
        end
        
        function gather_leaders(self)
            for i=1:length(self.lanes)
                lane = self.lanes(i);
                for k=1:length(lane)
                    car = lane(k);
                    if isempty(car.leader)
                        if isempty(self.leaders)
                            self.leaders = car;
                        else
                            self.leaders = [self.leaders, car];
                        end
                    end
                end
            end 
        end
        
        function b = car_in_leftmost_lane(self,car)
            b = 1;
            props = car.ticks.get_current_tick();
            if props.lane >= length(self.lanes)
                return
            end  
            b = 0;
        end
        
        function l = get_lane_left_of(self, lane)    
            if lane >= length(self.lanes)
                error('No lanes to the left!')
            end
            l = lane + 1;
        end        
        
%%%%%%% driver/main methods
        function perform_n_ticks(self, ticks)
            self.gather_leaders();
            for n=1:ticks
                for l = self.leaders
                    l.perform_properties_tick();
                end
                for l = self.leaders
                    l.perform_role_tick();
                end
            end
        end
    end
end