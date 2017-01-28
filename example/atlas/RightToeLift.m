classdef RightToeLift < Guard
    % The right toe lift event 
    %
    % The normal force on the right toe crosses zero
    
    properties
    end
    
    methods
        
        function obj = RightToeLift(model)
            % construct the right toe lift event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            
            obj = obj@Guard('RightToeLift',...
                'Condition', 'RightToe_normal_force',...
                'Direction', pos2neg);
        end
    end
    
end