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
        % @type char @default []
        name
                
        
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
        % options.use_floating_base = true.
        % 
        % @type double @default = 0
        nDof
        
        % The dimension of the floating base coordinates
        % 
        % @type double @default = 0
        nBase
        
        % The indexing vector of extended full coordiantes
        % 
        % @type rowvec
        qeIndices
        
        % The indexing vector of extended full coordiantes
        % 
        % @type rowvec
        dqeIndices
        
        % The indexing vector of joint coordiantes
        % 
        % @type rowvec
        qIndices
        
        % The indexing vector of joint coordinate velocities
        % 
        % @type rowvec
        dqIndices
        
        % The indexing vector of floating base coordiantes
        % 
        % @type rowvec
        qbIndices
        
        % The indexing vector of floating base coordinate velocities
        % 
        % @type rowvec
        dqbIndices
        
        % Custom options of the rigid body model
        %
        % Required fields of options:
        %  use_floating_base: specify whether use the floating base coordinates
        %  @type logical @default true
        %  floating_base_type: Specifies the type of the rigid body model. 
        %  The supported model types are 
        % - 'spatial' (6-dimensional floating base)
        % - 'planar'  (3-dimensional floating base)
        %
        % @type struct 
        options = struct(...
            'use_floating_base', true, ...
            'floating_base_type', 'spatial'...
            );
        
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
            
            % parse input options if applicable
            if nargin > 2
                obj.options = struct_overlay(obj.options,options);
            end
            
            % extract the absolute full file path of the input file
            full_file_path = GetFullPath(config_filename);
            
            % check if the file exists
            assert(exist(full_file_path,'file')==2,...
                'Could not find the input configuration file: \n %s\n', full_file_path);
            
            
            % assign the model name the same as the model config file name
            [~, model_file_name, config_type] = fileparts(full_file_path);
            obj = setModelName(obj, model_file_name);
            
                        
            %| @todo implement the URDF parser function 
            
            % load the model from the configuration file
            switch config_type
                case '.yaml'
                    urdf = cell_to_matrix_scan(yaml_read_file(full_file_path));
                case '.urdf'
                    urdf = parse_urdf(full_file_path);
            end
            
            
            obj = parseModel(obj, urdf.robot);
            
            
        end
        
        function obj = setModelName(obj, name)
            % Set the name of the model
            %
            % Parameters:
            %  name: the model name @type char
            %
            % Return values:
            %  obj:   the object of this class
            
            obj.name = name;
        end
        
        
    end
    
    %% Private methods
    
    
    %% Protected methods
    
end

