classdef ContinuousDomain
    % HybridDomain defines an admissible domain in the hybrid system model
    % 
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
    
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        name
        
        % The class option
        %
        % @type struct
        options
        
        % domain index in a step
        indexInStep
        numDomainsInStep
        
        % A struct array of contact points constraints
        %
        % Required fields of contactPoints:
        %  name: the name of the contact point @type char
        %  plink: the name of the rigid link on which the point is attached
        %  to @type char
        %  offset: the 3-dimensional offset in the body joint coordinates
        %  that is rigidly attached to parent link @type colvec
        %  constraints: the constraints imposed on the contact point. It
        %  should be a list of indices of some or all of available constraints
        %  given below
        %  - 1: the position along the X direction in the world frame
        %  - 2: the position along the Y direction in the world frame
        %  - 3: the position along the Z direction in the world frame
        %  - 4: the Euler rotation angle along the X direction in the world frame
        %  - 5: the Euler rotation angle along the Y direction in the world frame
        %  - 6: the Euler rotation angle along the Z direction in the world frame
        %
        % @type struct
        contactPoints
        
        % A struct array of additional kinematic constraints associated
        % with joints
        %
        % @type struct
        jointConstraints
        
        % A struct array of additional kinematic constraints associated
        % with kinematic positions
        %
        % @type struct
        posConstraints
        
        % the dimension of holonomic constraints
        %
        % @type integer
        dimHolConstr
        
        % a function that computes the value of holonomic constraints
        %
        % @type function_handle
        holConstrFunc 
        
        % afunction that computes the jacobian of holonomic constraints
        %
        % @type function_handle
        holConstrJac  
        
        % a function that computes time derivatives of the jacobian matrix
        % of holonomic constraints
        %
        % @type function_handle
        holConstrJacDot 
        
        
        controller
        
        %% virtual constraints (i.e., outputs)
        outputs
        nOutputs
        
        nParamRD1
        nParamRD2
        nParamPhaseVar
        
        
        ya1 % relative degree one output - actual
        ya2  % relative degree two outputs - actual
        yd1  % relative degree one output - desired
        yd2  % relative degree two outputs - desired
        
        % First order jacobian of outputs
        Dya1  % 1st Jacobian of relative degree one output - actual
        Dya2  % 1st Jacobian of relative degree two outputs - actual
        
        % Second order jacobian of outputs
        DLfya2 % 2nd Jacobian of relative degree two outputs - actual
        
        dyd1 % 1st derivative of desired degree one output w.r.t tau
        dyd2 % 1st derivative of desired degree two outputs w.r.t tau
        ddyd2 % 2nd derivative of desired degree two outputs w.r.t tau
       
        deltaphip   % Linearized hip position function handle
        Jdeltaphip % Jacobian of linearized hip position
        
        tau   % phase variable tau
        dtau  % time derivative of tau
        Jtau  % jacobian of tau w.r.t to system states x
        Jdtau % jacobian of dtau w.r.t to system states x
        
        nAct
        qaIndices
        dqaIndices
        
        
        %% domain parameters
        params
    end
    
    %% Public methods
    methods
        
        function obj = ContinuousDomain(name)
            % the default calss constructor
            %
            % Parameters:
            % name: the name of the hybrid domain @type char
            %
            % Return values:
            % obj: the class object
            
            % call the superclass constructor
            obj.name = name;
            
            % initialize the default options
            obj.options = struct(...
                'use_clamped_outputs', false);
            
        end
        
        function obj = configureDomain(obj, model, config_file)
            % Configure the hybrid domain model from a configuration file
            %
            % Parameters:
            %  model: the dynamical model @type RigidBodyModel
            %  config_file: the full file path of the configuration file
            %  @type char
            %  
            % Return values
            %  obj: configured hybrid domain object
            
            
            
            % extract the absolute full file path of the input file
            full_file_path = GetFullPath(config_file);
            
            % check if the file exists
            assert(exist(full_file_path,'file')==2,...
                'Could not find the input configuration file: \n %s\n', full_file_path);
            
            domainConfig = cell_to_matrix_scan(yaml_read_file(full_file_path));
            
            % Domain name
            obj.name  = domainConfig.name;
            
            %% domain index in a step
            obj.indexInStep      = domainConfig.indexInStep;
            obj.numDomainsInStep = domainConfig.numDomainsInStep;
            
            
            %% configure holonomic constraints
            obj = setHolonomicConstraints(obj, domainConfig.constraints);
            
            
            %% configure outputs
            obj = setOuputStructure(obj, domainConfig.outputs, model);
            
            
            % parse the input arguments
            %             p = inputParser;
            %             addRequired(p, 'name',@ischar);
            %             addOptional(p, 'contactPoints', [], @isstruct);
            %             addOptional(p, 'jointConstraints', [], @isstruct);
            %             addOptional(p, 'posConstraints', [], @isstruct);
            %             parse(p,varargin{:});
            %             inputs = p.Results;
            %
            %             % assign the domain name
            %             obj.name = inputs.name;
            %
            %             % if the contacts are given
            %             if ~isempty(inputs.contactPoints)
            %                 obj.contactPoints = inputs.contactPoints;
            %             end
            %
            %             % if the additional consraints are given
            %             if ~isempty(inputs.jointConstraints)
            %                 obj.jointConstraints = input.jointConstraints;
            %             end
            %             if ~isempty(inputs.posConstraints)
            %                 obj.posConstraints = input.posConstraints;
            %             end
        end
        
        function obj = setupController(obj,type)
            % setup the feedback controller for the continuous domain
            %
            % Parameters:
            %  type: controller type @type char
            obj.controller = FeedbackController(type);
        end
        
       
        
        function obj = addContactPoint(obj,varargin)
            % Add a contact point to the domain
            %
            %
            %
            
            % parse the input arguments
            p = inputParser;
            addRequired(p, 'name',@ischar);
            addRequired(p, 'plink',@ischar);
            addOptional(p, 'offset', zeros(1,3), ...
                @(x)(length(x)==3 && isnumeric(x)));
            addOptional(p, 'constraints', [], ...
                @(x)(isinteger(x) && ...
                x >= 0 && x <= 6 ));
            parse(p,varargin{:});
            new_contact = p.Results;
            
            % updates to the object contact property
            n_constr = length(obj.contactPoints);
            obj.contactPoints(n_constr+1) = new_contact;
        end
        
        function obj = addJointConstraints(obj,varargin)
            % Add a contact point to the domain
            %
            %
            %
            
            % parse the input arguments
            p = inputParser;
            addRequired(p, 'name',@ischar);         
            addRequired(p, 'vars',@ischar);
            addOptional(p, 'expr',{'var1'},@ischar);
            
            parse(p,varargin{:});
            new_contact = p.Results;
            new_contact.type = 'joint';
            
            
            n_constr = lenght(obj.jointConstraints);
            obj.jointConstraints(n_constr+1) = new_contact;
        end
        
        function obj = addPositionConstraints(obj,varargin)
            % Add a contact point to the domain
            %
            %
            %
            
            %| @todo make position constraints more general
            
            % parse the input arguments
            p = inputParser;
            addRequired(p, 'name',@ischar);         
            addRequired(p, 'vars',@ischar);
            addOptional(p, 'expr',{'var1'},@ischar);
            
            parse(p,varargin{:});
            new_contact = p.Results;
            new_contact.type = 'position';
            
            n_constr = lenght(obj.jointConstraints);
            obj.jointConstraints(n_constr+1) = new_contact;
        end
        
        function x0 = getInitialStates(obj)
           % return the initial states of the domain
           %
           % @note To call this function, first need to assign the params
           % structure
           %
           % Return values:
           % x0: the initial states of the domain
           
           x0 = obj.params.x_plus;
          
        end
        
    end
        
    
end

