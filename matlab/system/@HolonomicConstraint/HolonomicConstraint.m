classdef HolonomicConstraint < handle
    % HolonomicConstraint: represents a group of holonomic constraints of a
    % dynamical systems.
    %
    % A holonomic constraint is defined as a function of state variables
    % that equals to constants, i.e., 
    %   h(x) == hd
    %
    % @author ayonga @date 2017-04-20
    %
    % Copyright (c) 2016-2017, AMBER Lab
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
        
        % The symbolic representation of constant parameter value 'hd' that
        % the holonomic constraints associated wtih.
        %
        % @type SymVariable
        Param
        
        % The symbolic representation of the input variables associated
        % with the holonomic constraints
        %
        % @type SymVariable
        Input
    end
    
    % properties must be determined by the users
    properties (SetAccess=protected, GetAccess=public)
        % The name of the virtual constraints 
        %
        % @type char
        Name
        
        
        
        
        % The label of the holonomic constraint
        %
        % @type char
        ConstrLabel
        
        % The highest order of derivatives to enforce the holonomic
        % constraints. This is the same as the relative degree of a virtual
        % constraint.
        % 
        % @type integer
        DerivativeOrder
        
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
        
        % The name of the parameter variable 'hd' associated with the
        % holonomic constraints
        %
        % @type char
        ParamName
        
        % The name othe input variables (external forces, etc.) associated
        % with the holonomic constraints
        %
        % @type char
        InputName
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
        function name = get.ParamName(obj)
            name = ['p' obj.Name];
        end
        function name = get.InputName(obj)
            name = ['f' obj.Name];
        end
        function name = get.h_name(obj)
            name = ['h_' obj.Name '_' obj.Model.Name];
        end
        
        function name = get.Jh_name(obj)
            name = ['Jh_' obj.Name '_' obj.Model.Name];
        end
        
        function name = get.dJh_name(obj)
            name = ['dJh_' obj.Name '_' obj.Model.Name];
        end
        
        function name = get.dh_name(obj)
            name = ['dh_' obj.Name '_' obj.Model.Name];
        end
        
        function name = get.ddh_name(obj)
            name = ['ddh_' obj.Name '_' obj.Model.Name];
        end
    end
    
    properties (Dependent)
        
        h_name
        
        Jh_name
        
        dh_name
        
        dJh_name
        
        ddh_name
    end
    
    properties (Access = protected)
        % The dynamical system model
        %
        % @type DynamicalSystem
        Model
        
        
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
        
        function obj = HolonomicConstraint(model, h, name, varargin)
            % The class constructor function
            %
            % Parameters:
            % model: the dynamical system model in which the virtual
            % constraints are defined @type DynamicalSystem
            % h: the symbolic expression of the constraints
            % name: the name of the virtual constraints @type char
            % @type SymExpression
            % varargin: optional parameters. In details
            %  ConstrLabel: labels for constraints @type cellstr
            %  Jacobian: the custom Jacobian matrix @type SymExpression
            %  DerivativeOrder: the degree of holonomic constraints 
            %  @type integer
            
            
            
            if nargin == 0
                return;
            end
            
            % validate (model) argument
            validateattributes(model, {'ContinuousDynamics'},...
                {'scalar'},...
                'HolonomicConstraint','model');
            obj.Model = model;
            x = model.States.x;           
            
            % validates (name) argument
            validateName(obj, name);
            obj.Name = name;
            
            % parse the input options
            args = struct(varargin{:});
            assert(isscalar(args),...
                'The values of optional properties are must be scalar data.');
            
            
            if ~isempty(h)
                % validate (ya) argument
                validateattributes(h,{'SymExpression'},...
                    {'nonempty','vector'},...
                    'HolonomicConstraint','h');
                if isrow(h) % convert to column vector if it is a row vector
                    h = vertcat(h(:));
                end
            elseif isfield(args, 'LoadPath') && ~isempty(args.LoadPath)
                h = SymExpression([]);
                h = load(h, args.LoadPath, obj.h_name);
            else
                error(['Unable to create the HolonomicConstraint object. ',...
                    'Either the expression is empty or the load path is not specified.'],...
                    'HolonomicConstraint');
            end
            
            if isfield(args, 'LoadPath') && ~isempty(args.LoadPath)
                is_loaded = true;
            else
                is_loaded = false;
            end
            
            dim = length(h);
            obj.Dimension = dim;
            
            hd = SymVariable(obj.ParamName, [dim,1]);
            obj.Param = hd;
            obj.Input = SymVariable(obj.InputName,[dim,1]);
            
            if is_loaded % the loaded expression is h:= h_a - h_d
                obj.h_ = SymFunction(obj.h_name, h, {x, hd}); 
            else
                obj.h_ = SymFunction(obj.h_name, h-hd, {x, hd});
            end
           
            
            % validate and assign the desired outputs
            if isfield(args, 'ConstrLabel')
                obj.setConstrLabel(args.ConstrLabel);
            end
            
            if is_loaded
                Jh = SymFunction(obj.Jh_name, [], {model.States.x});
                obj.Jh_ = load(Jh,args.LoadPath);
            else
                if isfield(args, 'Jacobian')
                    obj.setJacobian(args.Jacobian);
                end
            end
            
            if isfield(args, 'DerivativeOrder')
                obj.setDerivativeOrder(args.DerivativeOrder);
            end
            
            if is_loaded
                obj.configure(args.LoadPath);
            else
                obj.configure();
            end
            
            
            
        end
        
        
        
    end
    
    
            
            
    
    
    methods
        
        % configure and compile the holonomic constraints
        obj = configure(obj, load_path);
        
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
            
        end
        
        
        
        
        % Jacobian matrix
        function obj = setJacobian(obj, jac)
            % sets the Jacobian matrix of the holonomic constraints if it
            % is provided directly by the users
            %
            % Parameters:
            % jac: the jacobian matrix @type SymExpression
            
            model = obj.Model;
            if nargin > 1
                validateattributes(jac,{'SymExpression'},...
                    {'2d','size',[obj.Dimension,model.numState]},...
                    'HolonomicConstraint','Jacobian');
            else
                jac = jacobian(obj.h_, model.States.x);
            end
            obj.Jh_ = SymFunction(obj.Jh_name, jac, {model.States.x});
        end
        
        % RelativeDegree
        function obj = setDerivativeOrder(obj, degree)
            % sets the highest derivative order of holonomic constraints in
            % order to enforce as bilateral constraints of the system
            % 
            % Parameters:
            % degree: derivative order @type integer
            
            if degree == 1
                error('Currently we do not support J(x)dx = 0 type of holonomic constraitns.')
            end
            
            validateattributes(degree, {'double'},...
                {'nonempty','scalar','positive','integer','>=',1,'<=',2},...
                'HolonomicConstraint','DerivativeOrder');
            obj.DerivativeOrder = degree;
             
        end
        
        % OutputLabel
        function obj = setConstrLabel(obj, label)
            % sets the naming labels of outputs
            %
            % Parameters:
            % label: the cell array of labels @type cellstr
            
            validateattributes(label,{'cell'},...
                {'nonempty','numel',obj.Dimension,'row'},...
                'HolonomicConstraint','ConstrLabel');
            cellfun( @(x) validateattributes(...
                x, {'char'},{}), label);
            
            obj.ConstrLabel = label;
        end
        
        
        % Name
        function name = validateName(~, name)
            validateattributes(name, {'char'},...
                {'nonempty','scalartext'},...
                'HolonomicConstraint','Name');
            
            assert(isempty(regexp(name, '\W', 'once')) || ~isempty(regexp(name, '\$', 'once')),...
                'HolonomicConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain special characters.');
            
            assert(isempty(regexp(name, '_', 'once')),...
                'HolonomicConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain ''_''.');
            
        end
    end
end

