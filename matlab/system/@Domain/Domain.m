classdef Domain
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
        HolonomicConstr
        
        
        %% unilateral constraints 
        % forces, distance
        %
        % @type struct
        UnilateralConstr
        
        
        
        % a structure of function names defined for the domain. Each field
        % of ''Funcs'' specifies the name of a function that used for a
        % certain computation of the domain.
        %
        % Required fields of funcs:
        %   Kin: a string of the function that computes the
        %   value of holonomic constraints @type char
        %   Jac: a string of the function that computes the
        %   jacobian of holonomic constraints @type char
        %   JacDot: a string of the function that computes time derivatives of the
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
            
            
            
            obj.HolonomicConstr = {};
            obj.UnilateralConstr = cell2table(cell(0,6),'VariableNames',...
                {'Name','Type','WrenchCondition','WrenchIndices','KinObject','KinFunction'});
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
       
        % The total dimension of the holonomic constraints defined on the
        % domain
        %
        % @type integer @default 0
        DimensionHolonomic
    end
    
    properties (Dependent, Hidden)
        
        % A symbol that represents the symbolic expressions of
        % the holonomic constraints in Mathematica. 
        %
        % Required fields of Symbols:
        % Kin: the holonomic constraints @type char
        % Jac: the Jacobian of the constraints `\partial{Kin}/\partial{q}`
        % @type char
        % JacDot: the time derivative of Jacobian @type char
        %
        % @type struct
        HolSymbols
        
        
    end % dependent properties
    
    
    methods
        function dim = get.DimensionHolonomic(obj)
            
            dim = sum(cellfun(@(x)getDimension(x),obj.HolonomicConstr));
        end
        
        function HolSymbols = get.HolSymbols(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            HolSymbols = struct(...
                'Kin',['$h["',obj.Name,'"]'],...
                'Jac',['$Jh["',obj.Name,'"]'],...
                'JacDot',['$dJh["',obj.Name,'"]']);
        end
        
     
    end % get methods
    
end % classdef

