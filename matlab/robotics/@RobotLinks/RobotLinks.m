classdef RobotLinks < ContinuousDynamics
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
    % @new{2,1, ayonga, 2017-03-26} Change RobotManipulator to RobotLinks
    % @new{2,0, ayonga, 2017-03-26} Change RigidBodyModel to RobotManipulator
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
        
        % An array of rigid links
        %
        % @type struct
        Links
        
        % An array of rigid joints
        %
        % @type RigidJoint
        Joints
        
        
        
       
    end
    
    
    
    
    
    %% Public methods
    methods
        
        
        function obj = RobotLinks(config, base, load_path, varargin)
            % The class constructor function
            %
            %
            % Parameters:
            % config: the configuration of the joints and links @type char           
            % base: the configuration of the floating base
            % coordinates  @type struct
            %
            % Return values:
            % obj: an object of this class
            
            
            % construct the object by calling superclass constructor
            % function
            obj = obj@ContinuousDynamics('SecondOrder');
            
            if nargin ==1 
                % the base joint is not specified, use default
                fprintf('The floating base coordinates are not configured. \n');
                fprintf('Setting it to the default 6 DOF floating base configuration ...\n');
                base = get_base_dofs('floating');
            end
            
            if nargin < 3
                load_path = [];
            end
            
            if nargin > 0
                configure(obj, config, base, load_path, varargin{:});
            end
            
        end
        
        
        
        
        
        
        
        
        
    end
    
    
    %% methods defined in seperate files
    methods
        
        obj = addContact(obj, contact, fric_coef, geometry, load_path);
        
        obj = addFixedJoint(obj, fixed_joints, load_path);
        
        obj = removeContact(obj, contact);
        
        
        
        base_link = findBaseLink(obj, joints);
        
        terminals = findEndEffector(obj, joints);
                
        indices = getLinkIndices(obj, link_names);
        
        indices = getJointIndices(obj, joint_names);
        
        
        obj = cconfigure(obj, config, base, load_path);
        
        obj = configureKinematics(obj, dofs, links);
        
        obj = configureDynamics(obj, varargin);
        
        obj = configureActuator(obj, dofs, actuators);
        
        ang = getRelativeEulerAngles(obj, frame, R, p);
        
        [varargout] = getCartesianPosition(obj, frame, p);
        
        [varargout] = getEulerAngles(obj, frame, p);
        
        [varargout] = getBodyJacobian(obj, frame, p);
        
        [varargout] = getSpatialJacobian(obj, frame, p);
        
        mass = getTotalMass(obj);        
        
        pos = getComPosition(obj);
        
        bounds = getLimits(obj);
        
        obj = loadDynamics(obj,file_path,skip_load_vf,extra_fvecs,varargin);
    end
    
    
    
end

