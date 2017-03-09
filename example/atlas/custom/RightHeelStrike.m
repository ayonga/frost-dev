classdef RightHeelStrike < Guard
    % The right heel strike event 
    %
    % The right heel height crosses zero
    
    properties
    end
    
    methods
        
        function obj = RightHeelStrike(model)
            % construct the right heel strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            
            obj = obj@Guard('RightHeelStrike',...
                'Condition', 'RightHeelPosZ',...
                'Direction', pos2neg);
            
            obj = setResetMap(obj, model, true);
        end
    end
    
end