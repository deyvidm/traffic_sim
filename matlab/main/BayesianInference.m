classdef BayesianInference < handle
    properties
        probability
        variance
        alpha
        beta
    end
    
    methods
        function obj = BayesianInference(alpha, beta)
            obj.alpha = alpha;
            obj.beta = beta;
        end
        
        function [p, v] = update(self, input)
            if input == 1
                self.alpha = self.alpha + 1;
            elseif input == 0
                self.beta = self.beta + 1;
            else
                error('Need 1 or 0')
            end
                    
            a = self.alpha;
            b = self.beta;
            
            p = a/(a+b);
            v = (a*b)/((a+b)^2 * (a+b+1));
        end
    end
end