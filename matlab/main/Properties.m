classdef Properties < handle
    properties
        acc
        speed
        pos
        
        % for lanes, the lower the number, the further to the left 
        % example: 3-lane road going in only 1 direction
        % lane 0 == leftmost lane
        % lane 1 == middle lane
        % lane 2 == rightmost lane
        
        % illustration: 
        % =======[ A ]=========>    Lane 0
        % =======[ B ]=========>    Lane 1
        % =======[ C ]=========>    Lane 2
        lane
    end
    
    methods
        function obj = Properties()
            obj.acc = 0;
            obj.speed = 0;
            obj.pos = 0;
            obj.lane = 0;
            
            
                
        end
        
%       Always keep this updated to reflect 
%       how many properties this class holds
        function l = length(self)
            l = 4;
        end
    end
end