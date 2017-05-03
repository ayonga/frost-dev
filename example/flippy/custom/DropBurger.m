classdef DropBurger < Guard
    % The left heel strike event 
    %
    % The left heel height crosses zero
    
    properties
    end
    
    methods
        
        function obj = DropBurger(model)
            % construct the drop event of the flippy robot
            % multi-contact walking
            
            
            
            pos2neg = 1;
            
            
            obj = obj@Guard('DropBurger',...
                'Condition', 'DeltaFinal',...
                'Direction', pos2neg);
            
            obj = setResetMap(obj, model, true);
        end
    end
    
end