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
        name
        
        % Specific options for the domain
        %
        % @type struct
        options
        
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
        
       
        %% actuation
        
        % a map for robot actuation on the current domain
        %
        % @type matrix
        actuator_map
        
        
        
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
        
        
        function obj = addPointContact(obj, pos, varargin)
            % Add a kinematic point contact
            % 
            % We use the terminology from Matt Mason's (CMU) lecture note. 
            % see 
            % http://www.cs.rpi.edu/~trink/Courses/RobotManipulation/lectures/lecture11.pdf
            %
            % A point contact with friction has 3 rotational degrees of
            % freedom. A point contact without friction has 
            %
            % Parameters:
            % pos: the contact point position of type struct
            % varargin: optional conditions. In detail
            % with_friction: true if there are frictions at the contact 
            % @type logicial @default true
            
            % parse variable input options
            p = inputParser;
            p.addParameter('with_friction', true, @islogical);            
            parse(p,varargin{:});
            
            with_friction = p.Results.with_friction;
            
            
            
            
        end
        
        function obj = addLineContact(obj, pos, varargin)
            % Add a kinematic line contact
            % 
            % We use the terminology from Matt Mason's (CMU) lecture note. 
            % see 
            % http://www.cs.rpi.edu/~trink/Courses/RobotManipulation/lectures/lecture11.pdf
            
            
        end
        
        function obj = addPlanarContact(obj, pos, varargin)
            % Add a kinematic planar contact
            % 
            % We use the terminology from Matt Mason's (CMU) lecture note. 
            % see 
            % http://www.cs.rpi.edu/~trink/Courses/RobotManipulation/lectures/lecture11.pdf
        end
        
        
    end % public methods
        
    %% Methods defined seperate files
    methods
        
        obj = setAcutation(obj, model, actuated_joints);
        
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

