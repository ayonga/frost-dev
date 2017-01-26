classdef RightToeStrike < Guard
    % The right toe strike event 
    %
    % The right toe height crosses zero
    
    properties
    end
    
    methods
        
        function obj = RightToeStrike()
            % construct the right toe strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            resetmap_options = struct(...
                'ApplyImpact', true,...
                'CoordinateRelabelMatrix', []);
            
            obj = obj@Guard('RightToeStrike',...
                'Condition', 'RightToePosZ',...
                'Direction', pos2neg,...
                'DeltaOpts', resetmap_options);
        end
    end
    
end