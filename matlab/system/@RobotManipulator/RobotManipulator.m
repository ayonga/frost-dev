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
        
        
        function obj = RobotManipulator(name, varargin)
            % The class constructor function
            %
            %
            % Parameters:
            % name: the name of the model @type char
            % config: the configuration of the joints and links @type char           
            % base: the configuration of the floating base
            % coordinates  @type struct
            %
            % Return values:
            % obj: an object of this class
           
            
            % construct the object by calling superclass constructor
            % function
            obj = obj@DynamicalSystem(name, 'SecondOrder');
            
            
            
            if nargin > 1
                configure(obj, varargin{:});
            end
            
        end
        
        
        
        
        
        
        
        
        
    end
    
    
    %% methods defined in seperate files
    methods
        base_link = findBaseLink(obj, joints);
        
        terminals = findEndEffector(obj, joints);
        
        obj = configureKinematics(obj, dofs, links);
        
        mass = getTotalMass(obj);
        
        indices = getLinkIndices(obj, link_names);
        
        indices = getJointIndices(obj, joint_names);
        
        pos = getComPosition(obj);
        
        obj = configureDynamics(obj);
        
        [M,f] = calcDynamics(obj, qe, dqe);
        
        
        [varargout] = getCartesianPosition(obj, varargin);
        
        [varargout] = getEulerAngles(obj, varargin);
        
        [varargout] = getBodyJacobian(obj, varargin);
        
        [varargout] = getSpatialJacobian(obj, varargin);
    end
    
    %% Private methods
    
    
end

