classdef HybridDomain
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
    
    %% Constant properties
    properties (Constant)
        %         possibleContraints = ...
        %             {'PosX',...
        %             'PosY',...
        %             'PosZ',...
        %             'Roll',...
        %             'Pitch',...
        %             'Yaw'};
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        % the name of the domain
        % 
        % @type char @default []
        name = [];
        
        
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
        jointConstrs
        
        % A struct array of additional kinematic constraints associated
        % with kinematic positions
        %
        % @type struct
        posConstrs
        
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
        
        % name of the guard condition
        %
        % @type char
        guardName
        
        % the direction of the guard
        %
        % Possible value of guardDir:
        %   - +1: if guard function cross zero from negative to positive
        %   - -1: if guard function cross zero from positive to negative
        %
        % @type integer @default -1        
        guardDir
        
        
        % the threshold of the guard condition, normally zero
        %
        % @type double @default 0
        guardThld
        
        % the type of guard condition
        %
        % @type char
        guardType  
        
        % the function handle to the function that computes the guard value
        %
        % @type function_handle
        guardFunc
        
        % the function handle to the function that computes the jacobian of guard
        %
        % @type function_handle
        guardJac
        
        % the reset map options
        %
        % Required fields for resetmap_options:
        %  hasImpact: indicates there is a rigid impact @type logical
        %  isSwapping: indicates whether swap the stant/non-stance legs
        %  @type logical @default false
        %
        % @type struct
        resetmap_options = struct(...
            'hasImpact',false,...
            'isSwapping',false);
        
        % function that computes the jacobian of impact constraints
        %
        % @type function_hanlde
        impConstrJac@function_handle
        
        
        %% virtual constraints (i.e., outputs)
        outputs@struct
        nOutputs@double
        
        nParamRD1@double
        nParamRD2@double
        nParamPhaseVar@double
        
        
        ya1@function_handle  % relative degree one output - actual
        ya2@function_handle  % relative degree two outputs - actual
        yd1@function_handle  % relative degree one output - desired
        yd2@function_handle  % relative degree two outputs - desired
        
        % First order jacobian of outputs
        Dya1@function_handle  % 1st Jacobian of relative degree one output - actual
        Dya2@function_handle  % 1st Jacobian of relative degree two outputs - actual
        
        % Second order jacobian of outputs
        DLfya2@function_handle % 2nd Jacobian of relative degree two outputs - actual
        
        dyd1@function_handle % 1st derivative of desired degree one output w.r.t tau
        dyd2@function_handle % 1st derivative of desired degree two outputs w.r.t tau
        ddyd2@function_handle % 2nd derivative of desired degree two outputs w.r.t tau
       
        deltaphip   % Linearized hip position function handle
        Jdeltaphip % Jacobian of linearized hip position
        
        tau@function_handle   % phase variable tau
        dtau@function_handle  % time derivative of tau
        Jtau@function_handle  % jacobian of tau w.r.t to system states x
        Jdtau@function_handle % jacobian of dtau w.r.t to system states x
        
        nAct@double
        qaIndices@double 
        dqaIndices@double
        
        
        %% domain parameters
        params@struct
    end
    
    %% Public methods
    methods
        
        function obj = HybridDomain(name)
            % The basic class constructor function
            
            % Domain name
            obj.name  = name;
            % parse the input arguments
            %             p = inputParser;
            %             addRequired(p, 'name',@ischar);
            %             addOptional(p, 'contactPoints', [], @isstruct);
            %             addOptional(p, 'jointConstrs', [], @isstruct);
            %             addOptional(p, 'posConstrs', [], @isstruct);
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
            %             if ~isempty(inputs.jointConstrs)
            %                 obj.jointConstrs = input.jointConstrs;
            %             end
            %             if ~isempty(inputs.posConstrs)
            %                 obj.posConstrs = input.posConstrs;
            %             end
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
            
            
            n_constr = lenght(obj.jointConstrs);
            obj.jointConstrs(n_constr+1) = new_contact;
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
            
            n_constr = lenght(obj.jointConstrs);
            obj.jointConstrs(n_constr+1) = new_contact;
        end
        
        
        
    end
        
    
end

