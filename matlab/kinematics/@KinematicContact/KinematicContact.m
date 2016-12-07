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
    
    % % The reference frame.
    % %
    % % It could be either ''body'' or ''spatial'', depends on in which
    % % reference frame the contact constraint is defined. If use
    % % ''body'' reference frame, then the contact constraint will be
    % % computed as the ''body'' coordinates of the parent link,
    % % otherwise if use ''spatial'' reference frame, it computes the
    % % contact in the world (inertial) frame.
    % %
    % % The reference frame only affects the way to compute the Jacobian
    % % of the contact constraint, and consequently will affects the
    % % direction of constraint wrenches. The position and the
    % % orientation (given as Euler angles of the parent link frame) of
    % % the contact point will always be represented in the world
    % % (inertial) frame.
    % %
    % % @type char
    % reference_frame
    
    properties 
        % The name of the parent rigid link on which the contact point is
        % attached to
        %
        % @type char
        ParentLink
        
        % The 3-dimensional offset of the contact point in the body
        % coordinate frame that is rigidly attached to parent link
        %
        % @type rowvec
        Offset
        
        
        
        % The normal axis of the contact given in the reference frame.
        %
        % It must be along one of the (x,y,z) axes. If the actual normal
        % axis is none of the three Cartesian axes, it would be better to
        % change the body coordinate frame so that the normal axis is along
        % the body coordinates axes.
        %
        % @note The normal axis should be the direction where the positive
        % normal force acts on. For example, we the 'z'-axis of the body
        % coordinate of the ParentLink points outward to the body, then the
        % NormalAxis should be '-z' axis.
        %
        % @type char
        NormalAxis
        
        
        % The tangent axis of the contact given in the reference frame
        % for Line contact
        %
        % It must be along one of the (x,y,z) axes. If the actual normal
        % axis is none of the three Cartesian axes, it would be better to
        % change the body coordinate frame so that the normal axis is along
        % the body coordinates axes.
        %
        %
        % @type char
        TangentAxis
        
        
        % The contact type
        % 
        % We use the terminology from Matt Mason's (CMU) lecture note.
        % see
        % http://www.cs.rpi.edu/~trink/Courses/RobotManipulation/lectures/lecture11.pdf
        % 
        % The following contact type is supported:
        % - 'PointContactWithFriction'
        % - 'PointContactWithoutFriction'
        % - 'LineContactWithFriction'
        % - 'LineContactWithoutFriction'
        % - 'PlanarContactWithFriction'
        % - 'PlanarContactWithoutFriction'
        %
        % @type char
        ContactType
        
        
        % The rigid model type, either ''planar'' or ''spatial''
        %
        % @type char @default 'spatial'
        ModelType
        
        % The positive friction coefficient if the contact has friction
        %
        % @type double
        Mu
        
        % The geometry shape of the contact if it is a line or planar
        % contact. 
        % 
        % These numbers will be used to compute unilateral constraints of
        % the contact wrenches. It consists of cell arrays with one string
        % specifies the axis of which the contact moment is computed ,and
        % one 1x2 vector specifies the distances to the rolling edges of
        % that axis. The first number specifies the distance to the rolling
        % edge for the positive moment and the second number specifies the
        % distance to the rolling edge for the negative moment. For more
        % detail, please refer to Eq. (28) and Fig. 3 in this article: 
        % Grizzle, J. W.; Chevallereau, C.; Sinnet, R. W. & Ames, A. D. 
        % Models, feedback control, and open problems of 3D bipedal robotic walking 
        % Automatica , 2014, 50, 1955 - 1988
        %
        % @note For a line contact, we assume the contact shape is a stick.
        %
        % @note For a planar contact, we assume the contact shape is a rectangler.
        %
        % @type cell
        Geometry
        
    end % properties
    
   
    properties (Dependent, Hidden, GetAccess=public)
        % the indices of constrained degrees of freedom of the
        % kinematic contact
        %
        % @type rowvec        
        ConstrIndices
        
    end
    
    properties (GetAccess=public, SetAccess=protected, Hidden)
        % The positive/negative sign of normal direction. In some cases,
        % the positive direction of the normal axis represented in the body
        % frame could points outward to the body. In these cases, the
        % normal force will be always negative. 
        %
        % @type double @default 1
        NormalAxisSign
    end
    
    
    
                    
    methods
        
        function obj = KinematicContact(varargin)
            % The constructor function
            %
            % Parameters: 
            %   varargin: it could be a struct has the same fields as this
            %   class or name-value pair arguments. The syntax would be
            %   similar to construct a struct in Matlab. Use either
            %   @verbatim kin = KinematicContact('Prop1', Value1,'Prop2',Value2,...); @endverbatim
            %   or 
            %   @verbatim kin = KinematicContact(KinStruct); @endverbatim
            %
            % See also: struct
            
            
            obj = obj@Kinematics(varargin{:});
            if nargin == 0 
                return;
            end
            
            
            if obj.Linearize
                warning('Do not linearize kinematic contact contraints.')
                obj.Linearize = false;
            end
            
            objStruct = struct(varargin{:});
            
            
            if isfield(objStruct, 'ParentLink')
                obj.ParentLink = objStruct.ParentLink;
            end
            
            if isfield(objStruct, 'NormalAxis')                
                obj.Axis = objStruct.Axis;
            end
            
            if isfield(objStruct, 'Offset')
                obj.Offset = objStruct.Offset;
            end
            
            if isfield(objStruct, 'TangentAxis')
                obj.TangentAxis = objStruct.TangentAxis;
            end
            
            if isfield(objStruct, 'ContactType')
                obj.ContactType = objStruct.ContactType;
            end
            
            if isfield(objStruct, 'ModelType')
                obj.ModelType = objStruct.ModelType;
            end
           
            
        end
        
        
        function dim = getDimension(obj)
            % Returns the dimension of the kinematic contact constraints
            
            
            dim = length(obj.ConstrIndices);
        end
    end % methods
    
    % methods overload in subclass
    methods (Access = protected)
        
        
        
        
        
        function cmd = getKinMathCommand(obj, model)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            valid_links = {model.Links.name};
            % validate parent link name (case insensitive)
            parent  = validatestring(obj.ParentLink,valid_links);
            
            
            if isempty(obj.Offset)
                error('The ''Offset'' of the position NOT assigned.');
            end
            
            % create a cell as the input argument
            arg = {parent,obj.Offset};
            % command for rigid position
            cmd = ['ComputeSpatialPositions[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.ConstrIndices),']]]'];
        end
        
        function cmd = getJacMathCommand(obj, model)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the Jacobian of kinematic constraint.
            
            valid_links = {model.Links.name};
            % validate parent link name (case insensitive)
            parent  = validatestring(obj.ParentLink,valid_links);
            
            
            if isempty(obj.Offset)
                error('The ''Offset'' of the position NOT assigned.');
            end
            
            % create a cell as the input argument
            arg = {parent,obj.Offset};
            % command for Jacobian
            cmd = ['ComputeBodyJacobians[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.ConstrIndices),']]]'];
            % switch obj.reference_frame
            %     case 'body'
            %         cmd = ['ComputeBodyJacobians[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.ConstrIndices),']]]'];
            %     case 'spatial'
            %         cmd = ['ComputeSpatialJacobians[',cell2tensor(arg),'][[1,Flatten[',mat2math(obj.ConstrIndices),']]]'];
            % end
        end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
    
    %% set/get methods
    methods
        
        function obj = set.Mu(obj, mu)
           
            if isreal(mu) && isscalar(mu) && mu > 0
                obj.Mu = mu;
            else
                error('The input must be a scalar positive real value.\n');
            end
        end
        
        
        function obj = set.Geometry(obj, geometry)
            
            if isempty(obj.ContactType) %#ok<MCSUP>
                error('The contact type is NOT specified. Please specify the contact type first.');
            end
            
            if regexp(obj.ContactType,'^PointContact\w*') %#ok<MCSUP> 
                % point contact
                warning('No geometry data required for point contact. Aborting ...');
                return;
            end
            
            if iscell(geometry) && size(geometry,2) == 2 && size(geometry,1) <= 2
                
                valid_axis = {'x','y','z'};
                if regexp(obj.ContactType,'^LineContact\w*') %#ok<MCSUP> 
                    % line contacts
                    assert(size(geometry,1)==1, ...
                        'For line contacts, only one dimensional geometry data required.');
                    assert(validatestring(geometry{1}{1},valid_axis),...
                        'The axis string is not a valid string. Expected to be one of the followings: \n %s',...
                        implode(valid_axis,', '));
                    assert(isreal(geometry{1,2})&&all(geometry{1,2} > 0)&&length(geometry{1,2})==2,...
                        'The geometry data is invalid. It must be a real positive vector of size 2. \n');
                    
                end
                if regexp(obj.ContactType,'^PlanarContact\w*') %#ok<MCSUP> 
                    % planar contacts
                    if strcmp(obj.ModelType,'spatial') %#ok<MCSUP>
                        assert(size(geometry,1)==2, ...
                            'For planar contacts of spatial model, two dimensional geometry data required.');
                        for i = 1:2
                            assert(any(validatestring(geometry{i,1},valid_axis)),...
                                'The axis string is not a valid string. Expected to be one of the followings: \n %s',...
                                implode(valid_axis,', '));
                            assert(isreal(geometry{i,2})&&all(geometry{i,2} > 0)&&length(geometry{i,2})==2,...
                                'The geometry data is invalid. It must be a real positive vector of size 2. \n');
                        end
                    elseif strcmp(obj.ModelType,'planar') %#ok<MCSUP>
                        assert(size(geometry,1)==1, ...
                            'For planar contacts of planar model, only one dimensional geometry data required.');
                        for i = 1:1
                            assert(any(validatestring(geometry{i,1},valid_axis)),...
                                'The axis string is not a valid string. Expected to be one of the followings: \n %s',...
                                implode(valid_axis,', '));
                            assert(isreal(geometry{i,2})&&all(geometry{i,2} > 0)&&length(geometry{i,2})==2,...
                                'The geometry data is invalid. It must be a real positive vector of size 2. \n');
                        end
                    else
                        error('The ''ModelType'' is NOT specified.');
                    end
                        
                end
                obj.Geometry = geometry;
                
            else
                error('The input must be cell array of size (1 x 2) or (2 x 2).');                
            end
        end
        
        
        function obj = set.ModelType(obj, type)
            
            valid_types = {'planar','spatial'};
            
            obj.ModelType = validatestring(type,valid_types);
        end
        
        
        function obj = set.ContactType(obj, type)
            
            valid_types = {'PointContactWithFriction',...
                'PointContactWithoutFriction',...
                'LineContactWithFriction',...
                'LineContactWithoutFriction',...
                'PlanarContactWithFriction',...
                'PlanarContactWithoutFriction'};
            
            obj.ContactType = validatestring(type,valid_types);
        end
        
        function obj = set.Offset(obj, offset)   
            
            % covnert to row vector first
            if iscolumn(offset)
                offset = offset';
            end
            % validate if it is a numeric 1x3 vector
            validateattributes(offset, {'numeric'},{'size',[1,3]});
            
            obj.Offset = offset;
            
        end
            
        
        function obj = set.ParentLink(obj, parent)
            
            assert(ischar(parent),'The ''ParentLink'' should be a valid string.');
            obj.ParentLink = parent;
        end
        
        function obj = set.NormalAxis(obj, axis)
            
            % set direction axis
            valid_axes = {'x','y','z','-x','-y','-z'};
            axis = validatestring(axis,valid_axes);
            
            if regexp(axis,'^-\w*') % negative axis
                obj.NormalAxis = axis(2:end);
                obj.NormalAxisSign = -1; %#ok<MCSUP>
            else
                obj.NormalAxis = axis;
                obj.NormalAxisSign = 1; %#ok<MCSUP>
            end
        end
        
        function obj = set.TangentAxis(obj, axis)
            
            % set direction axis
            valid_axes = {'x','y','z'};
            obj.TangentAxis = validatestring(axis,valid_axes);
        end
        
        
        function indices = get.ConstrIndices(obj)
            
            
            % all potential degrees of freedom
            dof_indices = [1, 2, 3, 4, 5, 6];
            
            % if the model is planar, then remove translation dof along y-axis
            % (2) and rotation along x-axis(4) and z-axis(6).
            if ~isempty(obj.ModelType)
                if strcmp(obj.ModelType, 'planar')
                    dof_indices([2,4,6]) = 0;
                end
            else
                error('The ''ModelType'' NOT specified.');
            end
            
            % remove the normal axis translation
            if ~isempty(obj.NormalAxis)
                dof_indices(strcmp(obj.NormalAxis,{'x','y','z'})) = 0;
            else
                error('The ''NormalAxis'' NOT specified.');
            end
                
            % if the contact is with friction, remove all three
            % translantional degrees of freedom
            if ~isempty(obj.ContactType)
                if regexp(obj.ContactType,'\w*WithFriction$')
                    dof_indices(1:3) = 0;
                end
            else
                error('The ''ContactType'' NOT specified.');
            end
            
            % if the contact is a line contact with friction, keep only the
            % tangent axis
            if strcmp(obj.ContactType,'LineContactWithFriction')
                rot_indices = dof_indices(4:6);
                if ~isempty(obj.TangentAxis)
                    rot_indices(~strcmp(obj.TangentAxis,{'x','y','z'})) = 0;
                else
                    error('The ''ContactType'' NOT specified.');
                end
                dof_indices(4:6) = rot_indices;
            end
            % if the contact is a line contact without friction, keep both
            % the normal axis and tangent axis
            if strcmp(obj.ContactType,'LineContactWithoutFriction')
                rot_indices = dof_indices(4:6);
                rot_indices(~(strcmp(obj.TangentAxis,{'x','y','z'}) + ...
                    strcmp(obj.NormalAxis,{'x','y','z'}))) = 0;
                dof_indices(4:6) = rot_indices;
            end
            
            % if the contact is a planar contact with friction, remove all three
            % rotational degrees of freedom
            if strcmp(obj.ContactType,'PlanarContactWithFriction')
                dof_indices(4:6) = 0;
            end
            
            % if the contact is a planar contact without friction, keep
            % only the rotation along the normal force
            if strcmp(obj.ContactType,'PlanarContactWithoutFriction')
                rot_indices = dof_indices(4:6);
                rot_indices(~strcmp(obj.NormalAxis,{'x','y','z'})) = 0;
                dof_indices(4:6) = rot_indices;
            end
            
            % keep all zero indcies
            indices = find(~dof_indices);
            
        end
    end
    
    %% methods defined in separate files
    methods (Access = public)
        [names, constraints] = getWrenchConstraint(obj, model, varargin);
    end
end % classdef
