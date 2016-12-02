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
        
        
        % kinematic constraints
        
        
        
        
        
        % the dimension of holonomic constraints
        %
        % @type integer
        dim_hol_constrs
        
        % a function that computes the value of holonomic constraints
        %
        % @type function_handle
        hol_constr_func 
        
        % afunction that computes the jacobian of holonomic constraints
        %
        % @type function_handle
        hol_constr_jac  
        
        % a function that computes time derivatives of the jacobian matrix
        % of holonomic constraints
        %
        % @type function_handle
        hol_constr_jacdot 
        
        
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
            %             addOptional(p, 'contact_positions', [], @isstruct);
            %             addOptional(p, 'joint_kin_constrs', [], @isstruct);
            %             addOptional(p, 'pos_kin_constrs', [], @isstruct);
            %             parse(p,varargin{:});
            %             inputs = p.Results;
            %
            %             % assign the domain name
            %             obj.name = inputs.name;
            %
            %             % if the contacts are given
            %             if ~isempty(inputs.contact_positions)
            %                 obj.contact_positions = inputs.contact_positions;
            %             end
            %
            %             % if the additional consraints are given
            %             if ~isempty(inputs.joint_kin_constrs)
            %                 obj.joint_kin_constrs = input.joint_kin_constrs;
            %             end
            %             if ~isempty(inputs.pos_kin_constrs)
            %                 obj.pos_kin_constrs = input.pos_kin_constrs;
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
            n_constr = length(obj.contact_positions);
            obj.contact_positions(n_constr+1) = new_contact;
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
            
            
            n_constr = lenght(obj.joint_kin_constrs);
            obj.joint_kin_constrs(n_constr+1) = new_contact;
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
            
            n_constr = lenght(obj.joint_kin_constrs);
            obj.joint_kin_constrs(n_constr+1) = new_contact;
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

