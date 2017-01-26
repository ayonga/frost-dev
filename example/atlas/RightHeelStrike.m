classdef RightHeelStrike < Guard
    % The right heel strike event 
    %
    % The right heel height crosses zero
    
    properties
    end
    
    methods
        
        function obj = RightHeelStrike()
            % construct the right heel strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            resetmap_options = struct(...
                'ApplyImpact', true,...
                'CoordinateRelabelMatrix', []);
            
            obj = obj@Guard('RightHeelStrike',...
                'Condition', 'RightHeelPosZ',...
                'Direction', pos2neg,...
                'DeltaOpts', resetmap_options);
        end
    end
    
end