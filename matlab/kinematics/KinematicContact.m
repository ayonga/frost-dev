classdef KinematicContact < Kinematics
    % Defines a kinematic contact constraint
    % 
    %
    % @author ayonga @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=protected, GetAccess=public)
        % The name of the parent rigid link on which the contact point is
        % attached to
        %
        % @type char
        parent
        
        % The 3-dimensional offset of the contact point in the body
        % coordinate frame that is rigidly attached to parent link
        %
        % @type rowvec
        offset
        
        % The reference frame.
        %
        % It could be either ''body'' or ''spatial'', depends on in which
        % reference frame the contact constraint is defined. If use
        % ''body'' reference frame, then the contact constraint will be
        % computed as the ''body'' coordinates of the parent link,
        % otherwise if use ''spatial'' reference frame, it computes the
        % contact in the world (inertial) frame.
        %
        % The reference frame only affects the way to compute the Jacobian
        % of the contact constraint, and consequently will affects the
        % direction of constraint wrenches. The position and the
        % orientation (given as Euler angles of the parent link frame) of
        % the contact point will always be represented in the world
        % (inertial) frame.
        %
        % @type char
        reference_frame
        
        % The normal axis of the contact given in the reference frame.
        %
        % It must be along one of the (x,y,z) axes. If the actual normal
        % axis is none of the three Cartesian axes, it would be better to
        % change the body coordinate frame so that the normal axis is along
        % the body coordinates axes.
        %
        % See also: KinematicPointContactWithoutFriction.reference_frame
        %
        % @type char
        normal_axis
        
        
        % The tangential axis of the contact given in the reference frame,
        % if the contact type is Line contacts
        %
        % It must be along one of the (x,y,z) axes. If the actual normal
        % axis is none of the three Cartesian axes, it would be better to
        % change the body coordinate frame so that the normal axis is along
        % the body coordinates axes.
        %
        % See also: KinematicPointContactWithoutFriction.reference_frame
        %
        % @type char
        tangential_axis
        
        
        % The contact type
        % 
        % We use the terminology from Matt Mason's (CMU) lecture note.
        % see
        % http://www.cs.rpi.edu/~trink/Courses/RobotManipulation/lectures/lecture11.pdf
        % 
        % A point contact without friction will have three rotational and two
        % translational degrees of freedom along the plane normal to the normal_axis.
        %
        % @type char
        contact_type
        
        % The indices of constrained degrees of freedom
        %
        % @type rowvec
        
        c_indices
    end % properties
    
   
    
    methods
        function c_indices = getDofIndices(obj, model)
            % The Get function for ''c_indices'' property
            %
            
            % all potential degrees of freedom
            dof_indices = [1, 2, 3, 4, 5, 6];
            
            % if the model is planar, then remove translation dof along y-axis
            % (2) and rotation along x-axis(4) and z-axis(6).
            if strcmp(model.type, 'planar')
                dof_indices([2,4,6]) = 0;
            end
            
            % remove the normal axis translation
            dof_indices(strcmp(obj.normal_axis,{'x','y','z'})) = 0;
                
            % if the contact is with friction, remove all three
            % translantional degrees of freedom
            if regexp(obj.contact_type,'\w*WithFriction$')
                dof_indices(1:3) = 0;
            end
                
            % if the contact is a line contact with friction, keep only the
            % tangential axis
            if strcmp(obj.contact_type,'LineContactWithFriction')
                rot_indices = dof_indices(4:6);
                rot_indices(~strcmp(obj.tangential_axis,{'x','y','z'})) = 0;
                dof_indices(4:6) = rot_indices;
            end
            % if the contact is a line contact without friction, keep both
            % the normal axis and tangential axis
            if strcmp(obj.contact_type,'LineContactWithoutFriction')
                rot_indices = dof_indices(4:6);
                rot_indices(~(strcmp(obj.tangential_axis,{'x','y','z'}) + ...
                   strcmp(obj.normal_axis,{'x','y','z'}))) = 0;
                dof_indices(4:6) = rot_indices;
            end
            
            % if the contact is a planar contact with friction, remove all three
            % rotational degrees of freedom
            if strcmp(obj.contact_type,'PlanarContactWithFriction')
                dof_indices(4:6) = 0;
            end
            
            % if the contact is a planar contact without friction, keep
            % only the rotation along the normal force
            if strcmp(obj.contact_type,'PlanarContactWithoutFriction')
                rot_indices = dof_indices(4:6);
                rot_indices(~strcmp(obj.normal_axis,{'x','y','z'})) = 0;
                dof_indices(4:6) = rot_indices;
            end
            
            % keep all zero indcies
            c_indices = find(~dof_indices);
        end
    end
    
                    
    methods
        
        function obj = KinematicContact(name, model, parent, offset, normal_axis, reference, type, tangential_axis, varargin)
            % The constructor function
            %
            % Parameters:            
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char        
            %  model: the rigid body model @type RigidBodyModel
            %  parent: the name of the parent link on which this fixed
            %  position is rigidly attached @type char                     
            %  offset: an offset of the point from the origin of the parent link
            %  frame @type rowvec @default [0,0,0]
            %  normal_axis: one of the (x,y,z) axis that gives the normal direction @type char
            %  type: the contact type
            %  tangential_axis: the tangential axis if it is a line contact
            %  varargin: superclass options @type varargin
            %
            % See also: Kinematics
            
            
            obj = obj@Kinematics(name, varargin{:});
            
            if obj.options.linearize
                warning('Do not linearize kinematic contact contraints.')
                obj.linearize = false;
            end
            
            if nargin > 1
                % check valid model object
                if isa(model,'RigidBodyModel')
                    valid_links = {model.links.name};
                else
                    error('Kinematics:invalidType',...
                        'The model has to be an object of RigidBodyModel class.');
                end
                
                % assign the parent link name (case insensitive)
                obj.parent  = validatestring(parent,valid_links);    
                
                % set point offset
                if isnumeric(offset) && length(offset)==3
                    if size(offset,1) > 1 % column vector
                        % convert to row vector
                        obj.offset = offset';
                    else
                        obj.offset = offset;
                    end                        
                end
               
                
                % set normal direction axis
                valid_axis = {'x','y','z'};
                obj.normal_axis = validatestring(normal_axis,valid_axis);
                
                
                
                
                valid_refs = {'body','spatial'};
                obj.reference_frame = validatestring(reference,valid_refs);
                
                
                valid_types = {'PointContactWithFriction',...
                    'PointContactWithoutFriction',...
                    'LineContactWithFriction',...
                    'LineContactWithoutFriction',...
                    'PlanarContactWithFriction',...
                    'PlanarContactWithoutFriction'};
                
                obj.contact_type = validatestring(type,valid_types);
                
                % if it is a line contact
                if regexp(obj.contact_type,'^LineContact\w*')
                    obj.tangential_axis = validatestring(tangential_axis,valid_axis);
                end
                
                obj.c_indices = getDofIndices(obj, model);
                
                obj.dimension = length(obj.c_indices);
            end
           
            
        end
        
        
        
        
    end % methods
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            % create a cell as the input argument
            arg = {obj.parent,obj.offset};
            % command for rigid position
            cmd = ['ComputeSpatialPositions[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.c_indices),']]]'];
        end
        
        function cmd = getJacMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the Jacobian of kinematic constraint.
            
            % create a cell as the input argument
            arg = {obj.parent,obj.offset};
            % command for Jacobian
            switch obj.reference_frame
                case 'body'
                    cmd = ['ComputeBodyJacobians[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.c_indices),']]]'];
                case 'spatial'
                    cmd = ['ComputeSpatialJacobians[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.c_indices),']]]'];
            end
        end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
