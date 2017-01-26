classdef LeftToeStrikeRelabel < Guard
    % The left toe strike event with coordinate relabelling
    %
    % The left toe height crosses zero
    
    properties
    end
    
    methods
        
        function obj = LeftToeStrikeRelabel(model)
            % construct the right toe strike event of the ATLAS
            % multi-contact walking
            
            
            
            joint_name = {model.Dof.name};
            % Indices of waist joints
            qWaistIndices = find(strncmpi(joint_name,'back_',5)+strncmpi(joint_name,'Torso',5));
            
            % Indices of right leg (arm) joints
            qRLegIndices = find(strncmpi(joint_name,'r_leg',5));
            
            % Indices of left leg (arm) joints
            qLLegIndices = find(strncmpi(joint_name,'l_leg',5));
    
            swappingIndices = cumsum(ones(model.nDof,1));
            swappingIndices(model.qbIndices)     = model.qbIndices;
            swappingIndices(qWaistIndices) = qWaistIndices;
            swappingIndices(qRLegIndices)  = qLLegIndices;
            swappingIndices(qLLegIndices)  = qRLegIndices;
            
            % find roll joints of both legs
            if strcmp(model.Type,'spatial')
                rollJoints = strfind(joint_name,...
                    'x');
                rollJointIndices = [model.qbIndices(4),...
                    find(~cellfun(@isempty,rollJoints))];
                
                
                % find yaw joints of both legs
                yawJoints = strfind(joint_name,...
                    'z');
                yawJointIndices = [model.qbIndices(6),...
                    find(~cellfun(@isempty,yawJoints))];
                
                swappingSign = ones(model.nDof,1);
                swappingSign(model.qbIndices(2)) = -1; % switch sign of y axis position
                swappingSign(rollJointIndices) = -1*ones(numel(rollJointIndices),1);
                swappingSign(yawJointIndices) = -1*ones(numel(yawJointIndices),1);
                
                relabel = diag(swappingSign);
            else
                relabel = diag(ones(model.nDof,1));
            end
            
            relabel_mat = relabel(swappingIndices,:);
            
            relabel_mat(1,1) = 0;
            relabel_mat(2,2) = 0;
            
            pos2neg = -1;
            
            resetmap_options = struct(...
                'ApplyImpact', true,...
                'CoordinateRelabelMatrix', relabel_mat);
            
            obj = obj@Guard('LeftToeStrike',...
                'Condition', 'LeftToePosZ',...
                'Direction', pos2neg,...
                'DeltaOpts', resetmap_options);
        end
    end
    
end