classdef RigidBodyModel < handle
    % A class with basic model descriptions and functionalities
    % of the multi-link rigid-body robot platform.
    %
    % References:
    % The descriptions of rigid body model is based on but not limited to
    % the following resrouces
    % - Richard Murray, Zexiang Li, and Shankar Sastry. "A Mathematical Introduction to Robotic
    % Manipulation". 1994, CRC Press. http://www.cds.caltech.edu/~murray/mlswiki.
    % - Roy Featherstones. "Rigid Body Dynamics Algorithm". Springer, 2008.
    % http://royfeatherstone.org/spatial/
    %
    % @author Ayonga Hereid @date 2016-09-26
    %
    % @new{1,0, ayonga, 2016-09-26} Migrated from old modelConfig class
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    %
    
    
    %% Public properties
    properties (Access = public)
    end
    
    %% Constant properties
    properties (Constant)
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
        % The unique name of the rigid body model
        %
        % @type char
        name
        
        % The type of the model, it could be either 'planar' or 'spatial'.
        %
        % @type char
        type
        
        % The full path of the model configuration file
        %
        % @type char
        config_file
        
        % Represents the list of rigid body links
        %
        % The link structure contains the elements of 'link'
        % specified in the URDF file.
        %
        % @type struct
        links
        
        % The axes list of base coordinates
        %
        % @type cell
        base_dof_axes
        
        %
        %         % Represents the list of rigid joints
        %         %
        %         % The joint structure contains the elements of 'joint'
        %         % specified in the URDF file.
        %         %
        %         % @type struct
        %         joints
        %
        %         % Represents the list of joint actuators
        %         %
        %         % The actuator structure contains the information of
        %         % joint actuators
        %         %
        %         % @type struct
        %         actuators
        %
        %         % A structure specifies the base joints of the rigid body model
        %         %
        %         % @type struct
        %         base_dofs
        
        % A structure describes the configuration of the total degrees of
        % freedom, including base coordinates
        %
        % @type struct
        dofs
        
        % The total degrees of freedom of the model
        %
        % It includes the dimensions of floating base coordinates if
        % options.use_floating_base = true.
        %
        % @type double
        n_dofs
        
        % The dimension of the floating base coordinates
        %
        % @type double
        n_base_dofs
        
        % The indexing vector of extended full coordiantes
        %
        % @type rowvec
        qe_indices
        
        % The indexing vector of extended full coordiantes
        %
        % @type rowvec
        dqe_indices
        
        % The indexing vector of joint coordiantes
        %
        % @type rowvec
        q_indices
        
        % The indexing vector of joint coordinate velocities
        %
        % @type rowvec
        dq_indices
        
        % The indexing vector of floating base coordiantes
        %
        % @type rowvec
        qb_indices
        
        % The indexing vector of floating base coordinate velocities
        %
        % @type rowvec
        dqb_indices
        
        
        
        % A model parameter structure constructed based on the requirement
        % of the Spatial Vector Algebra (sva) package
        % http://royfeatherstone.org/spatial/
        %
        % Required fields of sva:
        % NB: the number of bodies in the tree, including the
        %   fixed base. NB is also the number of joints plus the base
        %   coordinates, since we are interested in dynamics model in
        %   floating base coordinates. @type integer
        % parent: parent(i) is the body number of the parent of body
        %   i in the tree.  The fixed base is defined to be body number 0;
        %   and the remaining bodies are numbered from 1 to NB in any order
        %   such that each body has a higher number than its parent (so
        %   parent(i) < i for all i).  Joint i connects from body parent(i)
        %   to body i. @type rowvec
        % jtype: jtype{i} contains either the joint type
        %   code or the joint-descriptor data structure for joint i. Joint
        %   type codes are strings  and joint descriptors are data
        %   structures containing a field called code and an optional
        %   second field called pars, the former containing the joint type
        %   code and the latter any parameters that are needed by that type
        %   of joint. @type cell
        % Xtree: Xtree{i} is the coordinate transform from
        %   the coordinate system of body parent(i) to the coordinate
        %   system of the predecessor frame of joint i (which is embedded
        %   in body parent(i)).  The product of this transform with the
        %   joint transform for joint i, as calculated by jcalc, is the
        %   transform from body parent(i) coordinates to body i
        %   coordinates. @type cell
        % I: is the spatial or planar (as appropriate)
        %   inertia of body i, expressed in body i coordinates. @type cell
        % gravity: This is specifying the gravitational acceleration
        %   vector in base (body 0) coordinates. The dimension is either 2
        %   or 3, depending on whether the underlying arithmetic is planar
        %   or spatial.  If this field is omitted then a default value of
        %   [0;0;−9.81] is used in spatial models, and [0;-9.81] in planar
        %   models. @type rowvec
        %
        % Optional fields of sva:
        % type: model type @type char
        %
        % @type struct
        sva
        
        
        % A structured data keeps track of the symbolic expression
        % calculation status of the model in Mathematica.
        %
        % Required fields of status:
        %  initialized: indicates whether the model is initialized in
        %  Mathematica kernel @type logical
        %  compiled_dynamics: indicates whether the symbolic expressions
        %  for model dynamics are evaluated @type logical
        %  compiled_kinematics: indicates whether the symbolic expressions
        %  for model kinematics are evaluated @type logical
        %  exported_dynamics: indicates whether the symbolic expressions
        %  for model dynamics are exported as C++ source files @type
        %  logical
        %
        % @type struct
        status
    end
    
    %% Public methods
    methods
        
        
        function obj = RigidBodyModel(config_file, base_dofs, model_type)
            % The class constructor function
            %
            % @note To construct a rigid body model, a model URDF file
            % must be specified.
            %
            % Parameters:
            % config_filename: the full path of the model configuration
            % file. @type char
            % base_dofs: the base coordinates configuration of the model @type
            % struct                        
            % model_type: the type ('spatial' or 'planar') of the model.
            % The model type is in fact only being used if SVA package is
            % used @type char
            %
            % Return values:
            % obj: an object of this class
            %
            % Optional fields of base_dofs:
            %  type: Specifies the type of the rigid body model. @type char
            %  lower: the lower limits of each base joints @type rowvec
            %  upper: the upper limits of each base joints @type rowvec
            %  velocity: the velocity limits of each base joints @type
            %  axis: axes of each base joints. If not specified, then use
            %  default axes for each type. @type char
            %
            % @note The supported base joint types are:
            %   - floating: This joint allows motion for all 6 degrees of
            %   freedom. (default axes: {'Px','Py','Pz','Rx','Ry','Rz'})
            %   - planar: This joint allows motion in a plane perpendicular to
            %   the axis. (default axes: {'px','pz','r'})
            %   - revolute: a hinge joint that rotates along the axis and has a
            %   limited range specified by the upper and lower limits. (default
            %   axes: 'r')
            %   - continuous: a continuous hinge joint that rotates around the
            %   axis and has no upper and lower limits. (default
            %   axes: 'r')
            %   - prismatic: a sliding joint that slides along the axis, and
            %   has a limited range specified by the upper and lower limits. (default
            %   axes: 'pz')
            %   - fixed: This is not really a joint because it cannot move. All
            %   degrees of freedom are locked. This type of joint does not
            %   require the axis, calibration, dynamics, limits or
            %   safety_controller. (default axes: [])
            %
            % @note Non-default axes configuration for the base jonits are
            % prohibited in the current implementation, because it could
            % cause many unexpected issues. The options are still left for
            % the future extendability.
            %
            % For more definition regarding the supported joint type, please
            % see the URDF joint description at
            % http://wiki.ros.org/urdf/XML/joint
            
            
            if nargin == 0 % create an empty object
                return;
            end
            
            % parse the model configuration file
            [folder_name,file_name,file_ext] = fileparts(config_file);
            
            % check file type
            if isempty(file_ext)
                file_ext = '.urdf'; % default file type is URDF
                config_file = fullfile(folder_name, strcat(file_name,file_ext));
            else
                assert(strcmpi(file_ext,'.urdf'), 'RigidBodyModel:invalidFileType',...
                    ['Invalid file type detected: %s.\n',...
                    'It has to an URDF file.\n'],file_ext);
            end
            
            
            
            % extract the absolute full file path of the input file
            obj.config_file = GetFullPath(config_file);
            
            % check if the file exists
            assert(exist(obj.config_file,'file')==2,...
                'Could not find the model configuration file: %s\n', ...
                obj.config_file);
            
            
            
            
            if nargin < 2
                fprintf('The model type is not specified. Setting it to the default type ...\n');
                obj.type = 'spatial';
            else
                obj.type = model_type;
            end
            
            
            % configure base joint for the model
            if nargin < 3
                % the base joint is not specified, use default
                fprintf('The floating base coordinates are not configured. Setting it to the default configuration ...\n');
                base_dofs = struct();
                switch obj.type
                    case 'spatial'
                        base_dofs.type = 'floating';
                    case 'planar'
                        base_dofs.type = 'planar';
                end
                
                base_dofs.axis = defaultAxes(base_dofs.type);
                
                obj.n_base_dofs = numel(base_dofs.axis);               
                
                base_dofs.lower = -inf(1,obj.n_base_dofs);
                base_dofs.upper = inf(1,obj.n_base_dofs);
                base_dofs.velocity = inf(1,obj.n_base_dofs);
                base_dofs.effort = zeros(1,obj.n_base_dofs);
            else
                
                
                if ~isfield(base_dofs, 'type')
                    switch obj.type
                        case 'spatial'
                            base_dofs.type = 'floating';
                        case 'planar'
                            base_dofs.type = 'planar';
                    end
                elseif isempty(base_dofs.type)
                    switch obj.type
                        case 'spatial'
                            base_dofs.type = 'floating';
                        case 'planar'
                            base_dofs.type = 'planar';
                    end
                else
                    assert(~(strcmp(obj.type,'planar') && strcmp(base_dofs.type,'floating')),...
                        'RigidBodyModel:confictedConfiguration',...
                        'The planar type of model could not use floating type of base coordinates.\n');
                end
                
                if ~isfield(base_dofs, 'axis')
                    base_dofs.axis = defaultAxes(base_dofs.type);
                elseif isempty(base_dofs.axis)
                    base_dofs.axis = defaultAxes(base_dofs.type);
                else
                    fprintf('Non-default axes specified, it could cause unexpected issues.\n');
                    fprintf('Use it with extreme care!\n');
                    %                     base_dofs.axis = defaultAxes(base_dofs.type);
                end
                
                obj.n_base_dofs = numel(base_dofs.axis);
                
                if ~isfield(base_dofs, 'lower')
                    base_dofs.lower = -inf(1,obj.n_base_dofs);
                elseif isempty(base_dofs.lower)
                    base_dofs.lower = -inf(1,obj.n_base_dofs);
                end
                
                if ~isfield(base_dofs, 'upper')
                    base_dofs.upper = inf(1,obj.n_base_dofs);
                elseif isempty(base_dofs.upper)
                    base_dofs.upper = inf(1,obj.n_base_dofs);
                end
                
                if ~isfield(base_dofs, 'velocity')
                    base_dofs.velocity = inf(1,obj.n_base_dofs);
                elseif isempty(base_dofs.velocity)
                    base_dofs.velocity = inf(1,obj.n_base_dofs);
                end
                
                if ~isfield(base_dofs, 'effort')
                    base_dofs.effort = zeros(1,obj.n_base_dofs);
                elseif isempty(base_dofs.effort)
                    base_dofs.effort = zeros(1,obj.n_base_dofs);
                end
            end
            obj.base_dof_axes = base_dofs.axis;
            
            % load model from the URDF file
            model = loadModelFromURDF(obj);
            
            
            obj.name = model.name;
            obj.links = model.links;
            obj.n_dofs = obj.n_base_dofs + numel(model.joints);
            % Setup indices for fast operator
            obj = configureIndices(obj);
            
            obj.sva = configureSVA(obj,model, base_dofs);
            
            
            obj.dofs = configureDoFs(obj,model, base_dofs);
            
            
            % initialize status
            obj.status.initialized         = false;
            obj.status.compiled_dynamics   = false;
            obj.status.compiled_kinematics = false;
            obj.status.exported_dynamics   = false;
            
            
            function axes = defaultAxes(type)
                % This function returns the default axes list of the base joint
                
                switch type
                    case 'floating'
                        axes = {'Px','Py','Pz','Rx','Ry','Rz'};
                    case 'planar'
                        axes = {'px','py','r'};
                    case {'revolute','continuous'}
                        axes = {'r'};
                    case 'prismatic'
                        axes = {'px'};
                    case 'fixed'
                        axes = {};
                    otherwise
                        error('Invalid base joint type.\n');
                end
            end
            
        end
        
        
        
        
        
        
        
        
        
    end
    
    
    %% methods defined in seperate files
    methods
        obj = compileDynamics(obj);
    end
    
    %% Private methods
    
    
end

