classdef RigidBodyModel
    % RigidBodyModel A class with basic model descriptions and functionalities
    % of the rigid body robotic system.
    % 
    % References:
    % The descriptions of rigid body model is based on but not limited to
    % the following resrouces
    % - Richard Murray, Zexiang Li, and Shankar Sastry. "A Mathematical Introduction to Robotic
    % Manipulation". 1994, CRC Press. http://www.cds.caltech.edu/~murray/mlswiki.
    % - Roy Featherstones. "Rigid Body Dynamics Algorithm". Springer, 2008. 
    % http://royfeatherstone.org/spatial/>
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
        % @type char @default []
        name
        
        % Specifies the type of the rigid body model
        %
        % The supported model types are 
        % - 'spatial' (6-dimensional floating base)
        % - 'planar'  (3-dimensional floating base)
        %
        % @type char @default 'spatial'
        type = 'spatial';
        
        % Represents the list of rigid body links
        %
        % The link structure contains the elements of 'link' 
        % pecified in the URDF file. 
        %
        % @type struct
        links
        
        % Represents the list of rigid joints
        %
        % The joint structure contains the elements of 'joint'
        % specified in the URDF file. 
        %
        % @type struct 
        joints
        
        % Represents the list of joint actuators
        %
        % The actuator structure contains the information of 
        % joint actuators
        %
        % @type struct 
        actuators
        
        % The total degrees of freedom of the model
        %
        % It includes the dimensions of floating base coordinates if
        % options.floatingBase = true.
        % 
        % @type double @default = 0
        nDof
        
        
        % Custom options of the rigid body model
        %
        % Required fields of options:
        %  config_path: the full path of the model configuration file @type
        %  char
        %  config_type: the type of the model configuration file @type char
        % 
        % Optional fields of options:
        %  use_floating: specify whether use the floating base coordinates
        %  @type logical
        %
        % @type struct 
        options = struct(...
            'config_path',[],...
            'config_type',[],...
            'use_floating', true...
            );
        
        
        
    end
    
    %% Public methods
    methods
        
        
        function obj = RigidBodyModel(config_filename, options)
            % The class constructor function
            %
            % @note To construct a rigid body model, a model configuration file
            % must be specified. This file could be .urdf file or .yaml
            % file based on the definition of options.file_type
            %
            % Parameters:
            % config_filename: the full path of the model configuration
            % file. @type char
            % options: a struct that specifies custom options of the model
            % @type struct
            %
            % Return values:
            % obj: an object of this class
            
            
            % extract the absolute full file path of the input file
            full_file_path = GetFullPath(config_filename);
            [options.config_path, file_name, ext] = fileparts(full_file_path);
            
            if(~exist(full_file_path,'file'))
                error('Could not find the input configuration file.');
            end
            
            obj = SetModelName(obj, file_name);
            
            % the file extension represents the type of the configuration
            % file
            options.config_type = ext;
                        
            %| @todo implement the URDF parser function 
            
            % load the model from the configuration file
            switch options.config_type
                case '.yaml'
                    urdf = cell_to_matrix_scan(yaml_read_file(full_file_path));
                case '.urdf'
                    urdf = parse_urdf(full_file_path);
            end
            
            
            obj = parseModel(obj, urdf.robot);
            
            %
            obj.options = options;
        end
        
        function obj = SetModelName(obj, name)
            % Set the name of the model
            %
            % Parameters:
            %  name: the model name @type char
            %
            % Return values:
            %  obj:   the object of this class
            
            obj.name = name;
        end
        
        function obj = parseModel(obj, robot, options)
            % Parse the robot struct from URDF file into rigid body model
            %
            % Parameters:
            %  robot: the URDF robot model @type struct
            %  options: a struct that specifies custom options of the model
            % 
            % Return values:
            %  obj:   the object of this class
            obj.joints = robot.joints;
            obj.links  = robot.links;
            
            
        end
    end
    
    %% Private methods
    
    
    %% Protected methods
    
end

