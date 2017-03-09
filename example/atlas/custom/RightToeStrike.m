classdef RightToeStrike < Guard
    % The right toe strike event 
    %
    % The right toe height crosses zero
    
    properties
    end
    
    methods
        
        function obj = RightToeStrike(model)
            % construct the right toe strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            
            obj = obj@Guard('RightToeStrike',...
                'Condition', 'RightToePosZ',...
                'Direction', pos2neg);
            
            obj = setResetMap(obj, model, true);
        end
    end
    
end