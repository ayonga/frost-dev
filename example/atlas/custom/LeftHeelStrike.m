classdef LeftHeelStrike < Guard
    % The left heel strike event 
    %
    % The left heel height crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftHeelStrike(model)
            % construct the left heel strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            
            obj = obj@Guard('LeftHeelStrike',...
                'Condition', 'LeftHeelPosZ',...
                'Direction', pos2neg);
            
            obj = setResetMap(obj, model, true);
        end
    end
    
end