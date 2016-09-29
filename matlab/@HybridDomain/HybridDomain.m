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
        possibleContraints = ...
            {'PosX',...
            'PosY',...
            'PosZ',...
            'Roll',...
            'Pitch',...
            'Yaw'};
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
        %  should be an cell string of some or all of available constraints
        %  given below
        %  - 'PosX': the position along the X direction in the world frame
        %  - 'PosY': the position along the Y direction in the world frame
        %  - 'PosZ': the position along the Z direction in the world frame
        %  - 'Roll': the Euler rotation angle along the X direction in the world frame
        %  - 'Pitch': the Euler rotation angle along the Y direction in the world frame
        %  - 'Yaw': the Euler rotation angle along the Z direction in the world frame
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
        
    end
    
    %% Public methods
    methods
        
        function obj = HybridDomain(varargin)
            % The basic class constructor function
            
            % parse the input arguments
            p = inputParser;
            addRequired(p, 'name',@ischar);
            addOptional(p, 'contactPoints', [], @isstruct);
            addOptional(p, 'jointConstrs', [], @isstruct);
            addOptional(p, 'posConstrs', [], @isstruct);
            parse(p,varargin{:});
            inputs = p.Results;
            
            % assign the domain name
            obj.name = inputs.name;
            
            % if the contacts are given
            if ~isempty(inputs.contactPoints)
                obj.contactPoints = inputs.contactPoints;
            end
            
            % if the additional consraints are given
            if ~isempty(inputs.jointConstrs)
                obj.jointConstrs = input.jointConstrs;
            end
            if ~isempty(inputs.posConstrs)
                obj.posConstrs = input.posConstrs;
            end
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
                @(x)(iscellstr(x) && ...
                all(ismember(x,obj.possibleContraints))));
            parse(p,varargin{:});
            new_contact = p.Results;
            
            % updates to the object contact property
            n_constr = lenght(obj.contactPoints);
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

