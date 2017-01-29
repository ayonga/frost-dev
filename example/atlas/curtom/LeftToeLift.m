classdef LeftToeLift < Guard
    % The left toe lift event 
    %
    % The normal force on the left toe crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftToeLift(model)
            % construct the left toe lift event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            
            obj = obj@Guard('LeftToeLift',...
                'Condition', 'LeftToe_normal_force',...
                'Direction', pos2neg);
            
            
        end
    end
    
end