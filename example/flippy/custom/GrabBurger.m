classdef GrabBurger < Guard
    % The left heel strike event 
    %
    % The left heel height crosses zero
    
    properties
    end
    
    methods
        
        function obj = GrabBurger(model)
            % construct the grab event of the flippy model
     
            
            
            pos2neg = 1;
            
            
            obj = obj@Guard('GrabBurger',...
                'Condition', 'DeltaFinal',...
                'Direction', pos2neg);
            
            obj = setResetMap(obj, model);
        end
    end
    
end