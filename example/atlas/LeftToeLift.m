classdef LeftToeLift < Guard
    % The left toe lift event 
    %
    % The normal force on the left toe crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftToeLift()
            % construct the left toe lift event of the ATLAS
            % multi-contact walking
            
            
            
            pos2neg = -1;
            
            resetmap_options = struct(...
                'ApplyImpact', false,...
                'CoordinateRelabelMatrix', []);
            
            obj = obj@Guard('LeftToeLift',...
                'Condition', 'LeftToe_normal_force',...
                'Direction', pos2neg,...
                'DeltaOpts', resetmap_options);
        end
    end
    
end