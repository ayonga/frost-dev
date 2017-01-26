classdef LeftHeelStrike < Guard
    % The left heel strike event 
    %
    % The left heel height crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftHeelStrike()
            % construct the left heel strike event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            resetmap_options = struct(...
                'ApplyImpact', true,...
                'CoordinateRelabelMatrix', []);
            
            obj = obj@Guard('LeftHeelStrike',...
                'Condition', 'LeftHeelPosZ',...
                'Direction', pos2neg,...
                'DeltaOpts', resetmap_options);
        end
    end
    
end