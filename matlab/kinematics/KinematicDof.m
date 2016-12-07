classdef KinematicDof < Kinematics
    % Defines a single degrees of freedom (rigid joints) of the model
    % as kinematic constraints.
    % 
    %
    % @author Ayonga Hereid @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties 
        
        % the index of dof in the list of model.dofs
        %
        % @type char
        DofName
        
        
    end % properties
    
    
    methods
        
        function obj = KinematicDof(varargin)            
            % The constructor function
            %
            % @copydetails Kinematics::Kinematics()
            
            
            obj = obj@Kinematics(varargin{:});
            if nargin == 0
                return;
            end
            % the dimension is always 1
            obj.Dimension = 1;
            objStruct = struct(varargin{:});
            
            if isfield(objStruct, 'DofName')                
                obj.DofName = objStruct.DofName;
            end
        end
        
        
        function obj = set.DofName(obj, dof)
            
            assert(ischar(dof),'The ''DofName'' should be a valid string.');
            obj.ParentLink = dof;
        end
        
    end % methods
    
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj, model)
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            dof_index = getDofIndices(model, obj.DofName);
                
            assert(~isnan(obj.DofIndex),'KinematicDof:invalidDoF',...
                'The input DoF name is not found: %s',obj.DofName);

            % command for joint dofs
            cmd = ['ComputeJointConstraint[',num2str(dof_index),']'];
        end
        
        % use default function
        % function cmd = getJacMathCommand(obj)
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
