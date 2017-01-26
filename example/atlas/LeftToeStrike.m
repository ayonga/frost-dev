classdef LeftToeStrike < Guard
    % The left toe strike event 
    %
    % The left toe height crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftToeStrike()
            % construct the left toe strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            resetmap_options = struct(...
                'ApplyImpact', true,...
                'CoordinateRelabelMatrix', []);
            
            obj = obj@Guard('LeftToeStrike',...
                'Condition', 'LeftToePosZ',...
                'Direction', pos2neg,...
                'DeltaOpts', resetmap_options);
        end
    end
    
end