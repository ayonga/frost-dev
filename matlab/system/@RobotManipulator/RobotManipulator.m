classdef RobotManipulator < DynamicalSystem
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
    
    
    
    
    %% Constant properties
    properties (Constant)
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
              
        
        % The full path of the model configuration file
        %
        % @type char
        ConfigFile
        
        % Represents the list of rigid body links
        %
        % The link structure contains the elements of 'link'
        % specified in the URDF file.
        %
        % The required fields of Links:
        %  name: the name of the rigid link @type char
        %  mass: the mass of the rigid link @type double
        %  origin: the position and orientation of the origin @type struct
        %  inertia: the inertia matrix of the rigid link @type matrix
        %
        % The required fields of origin:
        %    rpy: the (roll,pitch,yaw) rotation of the link origin w.r.t. its
        %    parent joint
        %    xyz: the offset of the link origin w.r.t. its
        %    parent joint
        %
        % @type struct
        Links
        
        % A structure describes the configuration of the total degrees of
        % freedom, including base coordinates
        %
        %
        % The required fields of Joints:
        %  name: the name of the rigid joint @type char
        %  type: the type of the rigid joint @type char          
        %  origin: the position and orientation of the origin @type struct
        %  axis: the rotation axis of the joint @type rowvec
        %  parent: the parent link of the rigid joint @type char
        %  child: the child link of the rigid joint @type char
        %  limit: the limit of the rigid joint @type struct
        %
        % The required fields of origin:
        %  rpy: the (roll,pitch,yaw) rotation of the link origin w.r.t. its
        %  parent joint
        %  xyz: the offset of the link origin w.r.t. its
        %  parent joint
        %
        % The required fields of limit:
        %  effort: the maximum torque effort limit @type double
        %  lower: the lower bound of the joint @type double
        %  upper: the upper bound of the joint @type double
        %  velocity: the maximum velocity limit @type double
        %
        % @type struct
        Joints
        
        
        
       
    end
    
    
    %% Private properties
    properties (Access = public, Hidden)
        % The stuctured data of the forward kinematics twists
        %
        % @type SymExpression
        SymTwists      
        
        % A string of the Symbolic representation of the joints array
        %
        % @type SymExpression
        SymJoints
        
        % A string of the symbolic representation of the links array
        %
        % @type SymExpression
        SymLinks
    end
    
    
    %% Public methods
    methods
        
        
        function obj = RobotManipulator(config_file, base_config)
            % The class constructor function
            %
            % @note To construct a rigid body model, a model URDF file
            % must be specified.
            %
            % Parameters:
            % config_file: the full path of the model configuration
            % file. @type char           
            % base_config: the configuration of the floating base
            % coordinates  @type struct
            %
            % Return values:
            % obj: an object of this class
            %
            % @note The supported base_dofs types are:
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
            
            
            eval_math('Needs["RobotManipulator`"];');
            
            % parse the model configuration file
            [folder_name,file_name,file_ext] = fileparts(config_file);
            
            % check file type
            if isempty(file_ext)
                file_ext = '.urdf'; % default file type is URDF
                config_file = GetFullPath(fullfile(folder_name, [file_name,file_ext]));
            else
                assert(strcmpi(file_ext,'.urdf'), 'RigidBodyModel:invalidFileType',...
                    ['Invalid file type detected: %s.\n',...
                    'It has to an URDF file.\n'],file_ext);
            end
            
            
            
            
            
            % check if the file exists
            assert(exist(config_file,'file')==2,...
                'Could not find the model configuration file: %s\n', ...
                config_file);
            
            
            % load model from the URDF file
            [name, links, joints, transmissions] = ros_load_urdf(config_file);
            
            
            % construct the object by calling superclass constructor
            % function
            obj = obj@DynamicalSystem(name);
            
            joint2assoc = arrayfun(@struct2assoc,joints,'UniformOutput',false);
            
            base_link = eval_math(['GetBaseLink[' cell2tensor(joint2assoc,'ConvertString',false) ']']);
            base_link = base_link(2:end-1); % remove " " at two ends
            
            % configure base joint for the model
            if nargin < 2
                % the base joint is not specified, use default
                fprintf('The floating base coordinates are not configured. \n');
                fprintf('Setting it to the default 6 DOF floating base configuration ...\n');
                base_dofs = floating_base_config('floating', base_link);
            else
                if ischar(base_config)
                    base_dofs = floating_base_config(base_config, base_link);
                elseif isstruct(base_config)
                    base_dofs = base_config;
                else
                    error(['The second argument must be either a character vector of ',...
                        'the type of the floating base coordinates, or a structure array of base DOFs.'])
                end
            end
            
            joints = [base_dofs,joints];
            ndof = length(joints);
            % Add state variables
            x = SymVariable('x',[ndof,1],{joints.name});
            dx = SymVariable('dx',[ndof,1],{joints.name});
            ddx = SymVariable('ddx',[ndof,1],{joints.name});
            
            obj.addState(x,dx,ddx);
            
            if ~isempty(transmissions)
                % Add joint actuator inputs
                mechanicalReduction = zeros(1,numel(joints));
                for i=1:numel(joints)
                    if ~strcmp(joints(i).type,'fixed')
                        idx = str_index({transmissions.joint},joints(i).name);
                        if ~isempty(idx)
                            mechanicalReduction(i) = transmissions(idx).mechanicalReduction;
                        end
                    end
                end
                
                gf(mechanicalReduction~=0,:) = diag(mechanicalReduction(mechanicalReduction~=0));
                actuated_joints = joints(mechanicalReduction~=0);
                nact = length(actuated_joints);
                u = SymVariable('u',[nact,1],{actuated_joints.name});
                
                obj.addInput('u',u,gf);
            end
            % extract the absolute full file path of the input file
            obj.ConfigFile = GetFullPath(config_file);
            obj.Links = links;
            obj.Joints = joints;
            
            
            
            
            % Compute the forward kinematics of the robots
            obj.SymJoints = SymExpression(arrayfun(@struct2assoc,joints,'UniformOutput',false));
            obj.SymLinks = SymExpression(arrayfun(@struct2assoc,links,'UniformOutput',false));
            Qe = obj.States.x;
            obj.SymTwists = eval_math_fun('InitializeModel',{obj.SymJoints,Qe});
            
            % set the inertia matrix 
            De = eval_math_fun('InertiaMatrix',{obj.SymLinks,obj.SymTwists});
            obj.setMassMatrix(De);
        end
        
        
        
        
        
        
        
        
        
    end
    
    
    %% methods defined in seperate files
    methods
        mass = getTotalMass(obj);
        
        indices = getLinkIndices(obj, link_names);
        
        indices = getJointIndices(obj, joint_names);
        
        pos = getComPosition(obj);
        
        pos = getCartesianPosition(obj, varargin);
        
        pos = getEulerAngles(obj, varargin);
        
        [varargout] = getBodyJacobian(obj, varargin);
        
        [varargout] = getSpatialJacobian(obj, varargin);
    end
    
    %% Private methods
    
    
end

