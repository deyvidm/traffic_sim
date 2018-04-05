classdef Properties < handle
    properties
        acc
        speed
        pos
        lane
    end
    
    methods
        function obj = Properties()
            obj.acc = nan;
            obj.speed = nan;
            obj.pos = nan;
            obj.lane = nan;
        end
        
        function update(self, data)
            if ~isnan(data.acc)
                self.acc = data.acc; end
            if ~isnan(data.speed)
                self.speed = data.speed; end
            if ~isnan(data.pos)
                self.pos = data.pos; end
            if ~isnan(data.lane)
                self.lane = data.lane; end
        end
        
        function obj = clone(self)
            obj = Properties();
            obj.update(self);
        end
    end
end