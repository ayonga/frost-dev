classdef HybridDynamicalSystem
    % HybridDynamicalSystem defines a hybrid dynamical system that has both
    % continuous and discrete dynamics, such as bipedal locomotion.
    %
    % This class provides basic elements and functionalities of a hybrid
    % dynamicsl system. The mathematical definition of the hybrid system is
    % given as
    % \f{eqnarray*}{
    % \mathscr{HC} = \{\Gamma, \mathcal{D}, U, S, \Delta, FG\}
    % \f}
    %
    % @author Ayonga Hereid @date 2016-09-26
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    %% Public properties
    properties (Access = public)
    end
    
    %% Constant properties
    properties (Constant)
    end
    
    %% public properties
    properties
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        name
        
        % The directed graph that describes the hybrid dynamical system
        % structure
        %
        % @type DirectGraph
        gamma
        
        % The continuous domains
        %
        % @todo The current implementation is migrated from the old
        % 'domain' class, in which all elements (including continuous and
        % associated discrete events) are included in one class object.
        % Next step, separate them into multiple different classes
        % definition.
        %
        % @type HybridDomain array
        domains
        
        
        
        % The the rigid body model
        %
        % @type RigidBodyModel
        model
        
        % The hybrid flows (trajectory) recorder
        %
        % @type cell
        traj
        
               
        
        % The class option
        %
        % Required fields of options:
        %  simOpts: the simulation options @type struct
        %  odeOpts: the default options for ODE solvers
        %
        % Required fields of simOpts:
        %  ncycle: the number of cyclic motion of the periodic directed
        %          cycle @type integer @default 1
        %  startingVertex: the starting vertex in the graph
        %
        % @type struct
        options = struct(...
            'simOpts',[],...
            'odeOpts',[]);
        
        % the directory of configuration files
        %
        % @type char @default []
        configDirPrefix
    end
    
    %% Public methods
    methods (Access = public)
        function obj = HybridDynamicalSystem(name, config_path)
            % the default calss constructor
            %
            % Required fields of options:
            %  simOpts: the simulation options @type struct     
            %  odeOpts: the default options for ODE solvers
            %
            % Required fields of simOpts:
            %  ncycle: the number of cyclic motion of the periodic directed
            %          cycle @type integer @default 1
            %
            % Parameters:
            % name: the name of the hybrid system model @type char
            %
            % Return values:
            % obj: the class object
            
            % call the superclass constructor
            obj.name = name;
            
            % load default options 
            simOpts = struct();
            simOpts.ncycle = 1;
            simOpts.startingVertex = [];
            
            odeOpts = odeset('MaxStep', 1e-2, ...
                'RelTol',1e-6,...
                'AbsTol',1e-6);
            
            
            obj.configDirPrefix = config_path;
            obj.options.simOpts = simOpts;
            obj.options.odeOpts = odeOpts;
        end
        
        
        function obj = setGraph(obj, vertices, edges, graphOptions)
            % Configure the direct graph of the hybrid system model
            %
            % Parameters:
            %  vertices: the list of vertices @type cell
            %  edges: the source-target vertex pairs @type
            %  varargin: optional input arguments.
            %    edges: the pair list of edges @type cell @default []
            %    options: the graph options @type struct
            
            
            % set the direct graph using the name
            obj.gamma = DirectedGraph({vertices.name}, ...
                {{edges.name},{edges.source},{edges.target}}, graphOptions);
            
            nVertex = numel(vertices);
            new_domains = cell(1,nVertex);
            for i=1:nVertex
                domain_name = vertices(i).domain;
                % instantiated the hybrid domain first
                new_domains{i} = ContinuousDomain(domain_name);
                
                % the domain configuration file full path name
                domain_config_file = fullfile(obj.configDirPrefix,'config','domain',...
                    strcat(domain_name,'.yaml'));
                
                assert(~isempty(obj.model),['The dynamical model has not been configured. \n',...
                    'Please setup the dynamical model before the domain configuration.']);
                
                new_domains{i} = configureDomain(new_domains{i}, obj.model, domain_config_file);
                
                
                
            end
            
            obj.domains = [new_domains{:}];
            
            
            nEdge = numel(edges);
            new_edges = cell(1,nEdge);
            for i=1:nEdge
                guard_name = edges(i).guard;
                % instantiated the hybrid domain first
                new_edges{i} = DiscreteDynamics(guard_name);
                
                % the domain configuration file full path name
                dmap_config_file = fullfile(obj.configDirPrefix,'config','domain',...
                    strcat(guard_name,'.yaml'));
                
                % extract the absolute full file path of the input file
                full_file_path = GetFullPath(dmap_config_file);
                
                % check if the file exists
                assert(exist(full_file_path,'file')==2,...
                    'Could not find the input configuration file: \n %s\n', full_file_path);
                
                dMapConfig = cell_to_matrix_scan(yaml_read_file(full_file_path));
                
                new_edges{i} = setOptions(new_edges{i}, dMapConfig.resetMap);
                new_edges{i} = setGuard(new_edges{i}, dMapConfig.guard);
                
                
                
            end
        end
        
        
        
        
        
        
        
        %         function obj = configureSystemFromFile(obj, configFile)
        %             % This function configure the hybrid dynamical system model
        %             % from the specified existing YAML configuration file
        %             %
        %             % @note For the first time user, it is better to configure the
        %             % system step-by-step approach provided. The config file can be
        %             % exported from the already configured system.
        %
        %         end
        
        
        
        
        function obj = setModel(obj, urdf_file, model_options)
            % configure the dynamical system model
            %
            % Parameters:
            %  urdf_file: the file name 
            
            if nargin < 3
                model_options = [];
            end
            
            [~,file_name,file_ext] = fileparts(urdf_file);
            
            
            assert(~isempty(obj.configDirPrefix),...
                'Please set the configuration files path prefix first.\n');
             
            if isempty(file_ext)
                file_ext = '.urdf';
            end
            
            
            config_file = fullfile(obj.configDirPrefix,'config','model',...
                strcat(file_name,file_ext));
    
            % check if the file exists
            assert(exist(config_file,'file')==2,...
                'The configuration file could not be found.\n');
            
            obj.model = RigidBodyModel(config_file, model_options);
        end
        
       
       
        
        function domain = getDomainByVertex(obj, vertex)
            % Return the domain object associated with the vertex
            %
            % Parameters:
            %  vertex: the vertex string @type char
            % Return values:
            %  domain: the domain object associated with the vertex @type
            %  HybridDomain
        
            % check if graph has been configured a priori
            assert(~isempty(obj.gamma),... 
                'The graph is empty, please configure the graph first.\n');
        
            % check if the domains have been configured a priori
            assert(~isempty(obj.domains),...
                'The domain is empty, please configure the graph first.\n');
        
            % check if the given vertex name exists in the graph
            assert(any(strcmp(obj.vertices,vertex)),...
                'The vertex %s does not exist in the graph.\n',vertex);
        
            domain_index = strcmp(obj.gamma.vertices,vertex);
        
            domain = obj.domains(domain_index);
        
        
        end
    end
    
    methods
        function obj = set.configDirPrefix(obj, configDir)
            % Set the full path to the directory that contains all
            % configuration files
            %
            % Parameters:
            %  configDir: the full path string @type char
            
            % check if the directory exist
            assert(exist(configDir, 'dir') == 7,...
                ['The provided directory does not exist: \n',...
                '%s \n',...
                'Please provide the correct directory path.'], configDir);
            
            obj.configDirPrefix = configDir;
        end
    end
    
    %% Private methods
    methods (Access=private)
    end
    
end

