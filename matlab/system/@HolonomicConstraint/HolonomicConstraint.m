classdef HolonomicConstraint < handle
    % HolonomicConstraint: represents a group of holonomic constraints of a
    % dynamical systems.
    %
    % A holonomic constraint is defined as a function of state variables
    % that equals to constants, i.e., 
    %   h(x) == hd
    %
    % @author ayonga @date 2021-12-19
    %
    % Copyright (c) 2021, Cyberbotics Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    % properties determined internally
    properties (SetAccess=protected, GetAccess=public)
        % The dimension of the virtual constraints
        %
        % @type integer
        Dimension
        
        
        
        % The type (FirstOrder or SecondOrder) of the system
        %
        % @type char
        SystemType
        
        
        % The name of the virtual constraints 
        %
        % @type char
        Name
        
        
        % The label of the holonomic constraint
        %
        % @type char
        ConstrLabel
        
        
        % The parameter variable 'hd' associated with the
        % holonomic constraints
        %
        % @type ParamVariable
        Params
        
        % The relative degree of the holonomic constraints
        %
        % @type StateVariable
        RelativeDegree
    end

    
    properties (Dependent)
        % The holonomic constraint expression
        %
        % @type SymFunction
        ConstrExpr
        
        % The Jacobian matrix of the holonomic constraitns
        %
        % @type SymFunction
        ConstrJac
        
         % The Jacobian matrix of the holonomic constraitns
        %
        % @type SymFunction
        ConstrJacDot
        
        
    end
    
    %% GET methods
    methods 
        function cstr = get.ConstrExpr(obj)
            cstr = obj.h_;
        end
        function jac = get.ConstrJac(obj)
            jac = obj.Jh_;
        end
        function jacdot = get.ConstrJacDot(obj)
            jacdot = obj.dJh_;
        end
        
        
    end
    
    properties (SetAccess=protected, GetAccess=public)
        
        h_name
        
        Jh_name
        
        dh_name
        
        dJh_name
        
        ddh_name
        
        p_name
        
        f_name
    end
    
    properties (Access = protected)
        
        
        % The holonomic constraint expression
        %
        % @type SymFunction
        h_
        
        % The Jacobian matrix of the holonomic constraint expression
        %
        % @type SymFunction
        Jh_
        
        % The first order derivative of the holonomic constraint expression
        %
        % @type SymFunction
        dh_
        % The first order derivative of the Jacobian matrix of the
        % holonomic constraint expression
        % 
        %
        % @type SymFunction
        dJh_
        
        % The second order derivatives of the holonomic constraints
        % expression
        %
        % @type SymFunction
        ddh_
    end
    
    

   

  

    
    
    
    methods
        
        function obj = HolonomicConstraint(name, expr, model, options)
            % The class constructor function
            %
            % Parameters:            
            % name: the name of the virtual constraints @type char
            % expr: the symbolic expression of the constraints
            % model: the dynamical system model in which the unilateral
            % constraints are defined @type DynamicalSystem
            % options: name-value paired optional parameters. In details
            %  ConstrLabel: labels for constraints @type cellstr
            %  Jacobian: the custom Jacobian matrix @type SymExpression
            %  LoadPath: the path from which to load the symbolic
            %  expressions from @type char
            %  RelativeDegree: the relative degree of the constraints @type
            %  integer
            
            arguments
                name char {HolonomicConstraint.validateName(name)}
                expr (:,1) SymExpression {mustBeVector}
                model ContinuousDynamics 
                options.ConstrLabel (:,1) cell
                options.Jacobian (:,:) SymExpression 
                options.LoadPath char = ''
                options.RelativeDegree {mustBeMember(options.RelativeDegree,[1,2])} 
            end
            
            
            
            
            obj.Name = name;
            obj.SystemType = model.Type;
            
            obj.h_name = ['h_' name '_' model.Name];
            obj.Jh_name = ['Jh_' name '_' model.Name];
            obj.dh_name = ['dh_' name '_' model.Name];
            obj.dJh_name = ['dJh_' name '_' model.Name];
            obj.ddh_name = ['ddh_' name '_' model.Name];
            obj.p_name = ['p',name];
            obj.f_name = ['f',name];
            
            obj.Dimension = length(expr);
            
            hd = ParamVariable(obj.p_name, [obj.Dimension,1]);
            obj.Params = hd;
            obj.h_ = SymFunction(obj.h_name, expr-hd, {model.States.x, hd});
            
           
            if isfield(options, 'Jacobian')
                obj.setJacobian(options.Jacobian, model);
            end
            
            % validate and assign the desired outputs
            if isfield(options, 'ConstrLabel')
                obj.setConstrLabel(options.ConstrLabel);
            end
            
            if isfield(options, 'RelativeDegree')
                if strcmp(model.Type,'SecondOrder')
                    assert(options.RelativeDegree, ['The relative degree of ',... 
                        'holonomic constraints for a second-order system must be 2.'])
                end
                obj.RelativeDegree = options.RelativeDegree;
            else
                switch model.Type
                    case 'FristOrder'
                        obj.RelativeDegree = 1;
                    case 'SecondOrder'
                        obj.RelativeDegree = 2;
                end
            end
            
            
            obj.configure(model, options.LoadPath);
        end
        
        
        
    end
    
    
            
            
    
    
    methods
        
        % configure and compile the holonomic constraints
        obj = configure(obj, model, load_path);
        
        % enforce as NLP constraints
        nlp = imposeNLPConstraint(obj, nlp);
        
        % calculate the Jacobian matrix of the holonomic constraints
        [Jh, dJh] = calcJacobian(obj, x, dx);
        
        h = calcConstraint(obj, x);
        
        % save the symbolic expressions
        saveExpression(obj, export_path, varargin);
        
    end
    
    
    % set functions
    methods 
        
        
        function export(obj, export_path, varargin)
            % export the symbolic expressions of the constraints matrices and
            % vectors and compile as MEX files.
            %
            % Parameters:
            %  export_path: the path to export the file @type char
            %  varargin: variable input parameters @type varargin
            %   Vars: a list of symbolic variables @type SymVariable
            %   File: the (full) file name of exported file @type char
            %   ForceExport: force the export @type logical
            %   BuildMex: flag whether to MEX the exported file @type logical
            %   Namespace: the namespace of the function @type char
            
            
            export(obj.h_,export_path, varargin{:});
            
            export(obj.Jh_,export_path, varargin{:});
            
            if ~isempty(obj.dJh_)
                export(obj.dJh_,export_path, varargin{:});
            end
            
            %             export(obj.dh_,export_path, varargin{:});
            
            %             export(obj.ddh_,export_path, varargin{:});
            
        end
        
        
        
        
        % Jacobian matrix
        function obj = setJacobian(obj, jac, model)
            % sets the Jacobian matrix of the holonomic constraints if it
            % is provided directly by the users
            %
            % Parameters:
            % jac: the jacobian matrix @type SymExpression
            
            arguments
                obj 
                jac (:,:) SymExpression
                model DynamicalSystem
            end
            
            %             validateattributes(jac,{'2d','dimension',[obj.Dimension,model.Dimension]},...
            %                 'HolonomicConstraint','Size:wroingJacobianSize');
         
            [nr,nc] = dimension(jac);
            assert(nr==obj.Dimension || nc==model.Dimension,...
                'HolonomicConstraint:wrongJacobianSize: The provided jacobian dimension should be (%d x %d).',...
                obj.Dimension,model.Dimension);
            
            obj.Jh_ = SymFunction(obj.Jh_name, jac, {model.States.x});
            
        end
        
        
        % OutputLabel
        function obj = setConstrLabel(obj, label)
            % sets the naming labels of outputs
            %
            % Parameters:
            % label: the cell array of labels @type cellstr
            
            arguments
                obj 
                label (1,:) cell {iscellstr(label)}
            end
            
            obj.ConstrLabel = label;
        end
        
    end
    methods (Static)
        % Name
        function validateName(name)
            arguments
                name {mustBeValidVariableName}
            end
            
            assert(isempty(regexp(name, '_', 'once')),...
                'HolonomicConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain ''_''.');
            
        end
        
        
    end
end

