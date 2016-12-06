classdef Domain < handle
    % Domain defines an admissible continuous domain (or phase)
    % in the hybrid system model. The admissibility conditions are
    % determined by the constraints defined on the domain.
    % 
    % Contraints are typically given as kinematic constraints, such as
    % holonomic constraints and unilateral constraints, of the rigid body
    % model.
    %
    % @author ayonga @date 2016-09-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    
    %% Protected properties
    properties (SetAccess=private, GetAccess=public)
        
        %% basic properties
        
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        Name
        
        % Specific options for the domain
        %
        % @type struct
        Options
        
        %% holonomic constraints
        
        % a cell array of holonomic constraints given as objects of
        % Kinematics classes
        %
        % @type cell
        HolonomicConstraints
        
        %% unilateral constraints 
        % forces, distance
        %
        % @type table
        UnilateralConditions
        
        
        % a structure of function names defined for the domain. Each field
        % of 'funcs' specifies the name of a function that used for a
        % certain computation of the domain.
        %
        % Required fields of funcs:
        %   hol_constr: a string of the function that computes the
        %   value of holonomic constraints @type char
        %   jac_hol_constr: a string of the function that computes the
        %   jacobian of holonomic constraints @type char
        %   jacdot_hol_constr: a string of the function that computes time derivatives of the
        %   jacobian matrix of holonomic constraints @type char
        %
        % @type struct
        Funcs
        
       
        %% actuation
        
        % a map for robot actuation on the current domain
        %
        % @type matrix
        ActuationMap
        
        
        
    end
    
    
    
    %% Public methods
    methods
        
        function obj = Domain(name, varargin)
            % the calss constructor for Domain class
            %
            % Parameters:
            % name: the name of the domain @type char
            % varargin: the class options 
            %
            
            
            if ischar(name)
                obj.Name = name;
                % default names for functions
                obj.Funcs = struct();
                obj.Funcs.Kin = ['h_',obj.Name];
                obj.Funcs.Jac = ['Jh_',obj.Name];
                obj.Funcs.JacDot = ['dJh_',obj.Name];
            else
                error('The domain name must be a string.');
            end
            
            
            
            obj.HolonomicConstraints = {};
            % default options
            obj.Options = struct(); 
            
            %             obj.options = set_options(obj.options, varargin{:});
        end
        
        
        
        
        
    end % public methods
        
    %% Methods defined seperate files
    methods
        
        obj = setAcutation(obj, model, actuated_joints);
        
        
        obj = addHolonomicConstraint(obj, constr_list);
        
        obj = addUnilateralConstraint(obj, constr_list);
        
        obj = compileFunction(obj, model, field_names, varargin);
                
        obj = exportFunction(obj, export_path, do_build, field_names);
        
        
    end
    
    
    properties (Dependent)
       
        % the total dimension of holonomic constraints
        %
        % @type integer
        dim_hol_constr
        
        % A actual symbol that represents the symbolic expression of the
        % kinematic constraint in Mathematica.
        %
        % @type char
        hol_symbol
        
        % A symbol that represents the symbolic expression of the Jacobian
        % the kinematic constraint in Mathematica. 
        %
        % @type char
        hol_jac_symbol
        
        % A symbol that represents the symbolic expressions of the time
        % derivative of the kinematic constraint's Jacobian in Mathematica.
        %
        % @type char
        hol_jacdot_symbol
    end % dependent properties
    
    
    methods
        function dim = get.dim_hol_constr(obj)
            % the Get function of property ''dim_hol_constr''
            dim = sum(cellfun(@(x)x.dimension,obj.hol_constr));
        end
        function symbol = get.hol_symbol(obj)
            % The Get function of the property 'hol_symbol'
            symbol = ['$h["',obj.funcs.hol_constr,'"]'];
        end
        function symbol = get.hol_jac_symbol(obj)
            % The Get function of the property 'hol_jac_symbol'
            symbol = ['$Jh["',obj.funcs.jac_hol_constr,'"]'];
        end
        
        function symbol = get.hol_jacdot_symbol(obj)
            % The Get function of the property 'hol_jacdot_symbol'
            symbol = ['$dJh["',obj.funcs.jacdot_hol_constr,'"]'];
        end
    end % get methods
    
end % classdef

