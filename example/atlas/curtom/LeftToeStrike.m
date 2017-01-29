classdef LeftToeStrike < Guard
    % The left toe strike event 
    %
    % The left toe height crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftToeStrike(model)
            % construct the left toe strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            
            obj = obj@Guard('LeftToeStrike',...
                'Condition', 'LeftToePosZ',...
                'Direction', pos2neg);
            
            obj = setResetMap(obj, model, true);
        end
    end
    
end