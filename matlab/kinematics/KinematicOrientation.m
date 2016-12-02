classdef KinematicOrientation < Kinematics
    % Defines three dimensional orientations of a body frame rigidly
    % attached to a link, i.e., it belongs to SO(3).
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
    
    properties (SetAccess=protected, GetAccess=public)
        % The parent link name of the body frame
        %
        % @type char
        parent
        
        % The (x,y,z)-axis index of the position
        %
        % @type integer
        axis
    end % properties
    
    
    methods
        
        function obj = KinematicOrientation(name, model, parent, axis, varargin)
            % The constructor function
            %
            % Parameters:            
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char        
            %  model: the rigid body model @type RigidBodyModel
            %  parent: the name of the parent link on which this fixed
            %  position is rigidly attached @type char             
            %  axis: one of the (x,y,z) axis @type char          
            %  linear: indicates whether linearize the original
            %  expressoin @type logical
            
            
            obj = obj@Kinematics(name);
            
            
            
            if isa(model,'RigidBodyModel')
                valid_links = {model.links.name};
            else
                error('Kinematics:invalidType',...
                    'The model has to be an object of RigidBodyModel class.');
            end
            
            
            valid_axis = {'x','y','z'};
            
            % parse inputs
            
            p = inputParser();
            p.addRequired('parent', @(x) any(validatestring(x,valid_links)));
            p.addRequired('axis', @(x) any(validatestring(axis,valid_axis)));
            p.addParameter('linear', obj.linear, @islogical);
            
            parse(p, parent, axis, varargin{:});
            
            obj.parent = p.Results.parent;
            obj.axis   = find(strcmpi(p.Results.axis, valid_axis));
            obj.linear = p.Results.linear;
            
            
        end
        
        
        function obj = setLinkFrame(obj, model, parent)
            % Sets the fixed positionn
            %
            % Parameters:
            %  model: the rigid body model @type RigidBodyModel
            %  parent: the name of the parent link on which this fixed
            %  position is rigidly attached @type char
            
            if ~isa(model,'RigidBodyModel')
                error('Kinematics:invalidType',...
                    'The model has to be an object of RigidBodyModel class.');
            end
            
            valid_links = {model.links.name};
            if any(validatestring(parent,valid_links))
                obj.parent = parent;
            end
            
        end
        
        
        function obj = setDirection(obj, axis)
            % Set the direction of the orientation
            %
            % Parameters:
            %  axis: one of the (x,y,z) axis @type char
            
            valid_axis = {'x','y','z'};
            if any(validatestring(axis,valid_axis))
                obj.axis = axis;
            end
        end
        
    end % methods
    
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            % create a cell as the input argument, use zero offsets
            arg = {obj.parent,[0,0,0]};
            % class specific command for computing orientation based kinematic constraint
            cmd = ['{ComputeEulerAngles[',cell2tensor(arg),'][[1,',num2str(obj.axis),']]}'];
        end
        
        % overload the Jacobian compilation command
        function cmd = getJacMathCommand(obj)
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint's Jacobian.
            
            % create a cell as the input argument, use zero offsets
            arg = {obj.parent,[0,0,0]};
            % class specific command for computing rotational spatial Jacobian of an orientation
            cmd = ['{ComputeRotationalJacobians[',cell2tensor(arg),'][[1,',num2str(obj.axis),']]}'];
        end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
