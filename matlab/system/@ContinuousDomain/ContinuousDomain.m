classdef ContinuousDomain < handle
    % ContinuousDomain defines an admissible continuous domain (or phase)
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
        name
        
        
        %% holonomic constraints
        
        % a cell array of holonomic constraints given as objects of
        % Kinematics classes
        %
        % @type cell
        hol_constr
        
        % a cell string of holonomic constraint names defined on the domain
        %
        % @type cellstr
        hol_constr_names
        
        % the number of holonomic constraints
        %
        % @type integer
        n_hol_constr
        
        
        
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
        funcs
        
       
        
        % Specific options for the domain
        %
        % @type struct
        options
        
        
        
    end
    
    
    
    %% Public methods
    methods
        
        function obj = ContinuousDomain(name)
            % the default calss constructor
            %
            % Parameters:
            % name: the name of the domain @type char
            %
            % Return values:
            % obj: the class object
            
            if nargin > 0
                if ischar(name)
                    obj.name = name;
                else
                    warning('The domain name must be a string.');
                end
            end
            
            
            obj.hol_constr = {};
            
            % default names for functions            
            obj.funcs = struct();
            obj.funcs.hol_constr = ['hol_',obj.name];
            obj.funcs.jac_hol_constr = ['jac_hol_',obj.name];
            obj.funcs.jacdot_hol_constr = ['jacdot_hol_',obj.name];
            
            % default options
            obj.options = struct(); 
        end
        
        
    end % public methods
        
    %% Methods defined seperate files
    methods
        
        obj = setFunctionName(obj, fields, values);
        
        obj = addConstraint(obj, constr_list);
        
        obj = removeConstraint(obj, constr_list);
        
        obj = compileFunction(obj, model, field_names, varargin);
                
        obj = exportFunction(obj, export_path, do_build, field_names);
        
        [hol, Jhol, dJhol] = calcHolonomicConstraint(obj, q, dq);
    end
    
    
    properties (Dependent)
       
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

