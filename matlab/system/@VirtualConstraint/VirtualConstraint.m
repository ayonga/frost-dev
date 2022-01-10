classdef VirtualConstraint < handle
    % VirtualConstraint: represents a group of virtual constraints of a
    % dynamical systems.
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
        
        
        % An indicator that shows there is a parameter variable for phase
        %
        % @type logical
        hasPhaseParam logical = false;
        
        % The symbolic representation of parameter sets of the desired
        % outputs
        % 
        % @type ParamVariable
        OutputParams
        
        
        % The symbolic representation of parameters of the phase variable
        %
        % @type ParamVariable
        PhaseParams
    end
    
    % properties must be determined by the users
    properties (SetAccess=protected, GetAccess=public)
        % The name of the virtual constraints 
        %
        % @type char
        Name
        
        
        
        
        % The label of the virtual constraint
        %
        % @type char
        OutputLabel
        
        
        % The type of the phase variable
        % 
        % It could be either 'StateBased' or 'TimeBased'
        %
        % @type char
        PhaseType
        
        % The type of the desired output function
        %
        % It could be one of the following functions:
        % {'Bezier','CWF','ECWF','MinJerk','Constant'}
        %
        DesiredType
        
        % The relative degree of the output
        % 
        % @type integer
        RelativeDegree
        
        % Indicates whether the virtual constraint is holonomic or
        % nonholonomic constraints
        %
        % @type logical
        IsHolonomic

        
        % The maximum degree of the polynomial function
        %
        % @type integer
        PolyDegree
        
        % The actual outputs
        %
        % @type SymFunction
        ActualFuncs
        
        % The desired outputs
        %
        % @type SymFunction
        DesiredFuncs
        
        % The phase variable
        %
        % @type SymFunction
        PhaseFuncs%
        
        % The virtual constraints ya - yd functions
        %
        % @type SymFunction
        OutputFuncs
    
    end

    properties (Dependent)
        % The phase variable
        %
        % @type SymExpression
        PhaseVariable
        
        % The actual outputs
        %
        % @type SymExpression
        ActualOutput
        
        % The desired outputs
        %
        % @type SymExpression
        DesiredOutput
        
        % The name of the phase parameter variable
        % 
        % @type char%
        PhaseParamName
        
        % The name of the output parameter variable
        % 
        % @type char
        OutputParamName
        
    end
    
    methods
        function var = get.PhaseVariable(obj)
            var = obj.tau_;
        end
        function ya = get.ActualOutput(obj)
            ya = obj.ya_;
        end
        function yd = get.DesiredOutput(obj)
            yd = obj.yd_;
        end
        function name = get.PhaseParamName(obj)
            name = ['p' obj.Name];
        end
        function name = get.OutputParamName(obj)
            name = ['a' obj.Name];
        end
    end
    
    
    properties (Access = protected)
        % The dynamical system model
        %
        % @type DynamicalSystem
        Model
        
        
        % The actual outputs
        %
        % @type SymExpression
        ya_
        
        % The desired outputs
        %
        % @type SymExpression
        yd_
        
        
        % The phase variables
        %
        % @type SymExpression
        tau_
        
        
        
        
        % The actual outputs
        %
        % @type char
        ActualFuncsName_
        
        % The desired outputs
        %
        % @type char
        DesiredFuncsName_
        
        % The phase variable
        %
        % @type char
        PhaseFuncsName_
        
        % The virtual constraints ya - yd functions
        %
        % @type char
        OutputFuncsName_
    end
    
    

   

  

    
    
    
    methods
        
        function obj = VirtualConstraint(name, expr, model, derivatives, options)
            % The class constructor function
            %
            % Parameters:
            % model: the dynamical system model in which the virtual
            % constraints are defined @type DynamicalSystem
            % ya: the symbolic expression of the actual outputs 
            % name: the name of the virtual constraints @type char
            % @type SymExpression
            % varargin: optional parameters. In details
            %  DesiredType: 
            %  PolyDegree:
            %  RelativeDegree:
            %  PhaseType:
            %  Holonomic:
            %  OutputLabel:
            %
            
            arguments
                name char {VirtualConstraint.validateName(name)}
                expr (:,1) SymExpression {mustBeVector}
                model ContinuousDynamics 
            end
            arguments (Repeating)
                derivatives SymExpression
            end
            arguments
                options.DesiredType char {mustBeMember(options.DesiredType,{'Bezier','CWF','ECWF','MinJerk','Constant'})}
                options.PolyDegree double {mustBeInteger,mustBeGreaterThan(options.PolyDegree,1),mustBeScalarOrEmpty}
                options.OutputLabel (:,1) cell
                options.RelativeDegree double {mustBeInteger,mustBePositive} 
                options.PhaseType char {mustBeMember(options.PhaseType,{'StateBased','TimeBased'})} 
                options.PhaseVariable (1,1) SymExpression {mustBeScalarOrEmpty}
                options.PhaseParams ParamVariable
                options.IsHolonomic logical = true
                options.LoadPath char = ''
            end
            
            
            % validate (model) argument
            obj.Model = model;
            obj.Name = name;
            obj.ya_ = expr;
            obj.Dimension = length(expr);
                        
            
            
            % validate and assign the desired outputs
            
            
            if isfield(options, 'DesiredType')
                if isfield(options, 'PolyDegree')
                    obj.setDesiredType(options.DesiredType, options.PolyDegree);
                else
                    obj.setDesiredType(options.DesiredType);
                end
            else
                error('The desired output function type (DesiredType) must be given.');
            end
            
            if isfield(options, 'OutputLabel')
                obj.setOutputLabel(options.OutputLabel);
            end
            
            if isfield(options, 'RelativeDegree')
                obj.setRelativeDegree(options.RelativeDegree);
            else
                error('The relative degree of the virtual constraints (RelativeDegree) must be defined.');
            end
            
            if isfield(options, 'PhaseType')
                obj.setPhaseType(options.PhaseType);
            else
                error('The type of phase variable (PhaseType) must be given.');
            end
            
            if isfield(options, 'PhaseVariable')
                if isfield(options, 'PhaseParams')
                    obj.setPhaseVariable(options.PhaseVariable, options.PhaseParams);
                else
                    obj.setPhaseVariable(options.PhaseVariable);
                end
            end
            
            
            if isfield(options, 'IsHolonomic')
                obj.setHolonomic(options.IsHolonomic);
            else
                error('Please determine whether the virtual constraint is holonomic (Holonomic) or not.');
            end
            
            
            
            obj.configure(options.LoadPath, derivatives);
            
        end
        
        
        
    end
    
    
            
            
    methods (Access = private)
        function [yd,a] = getDesiredOutput(obj, type, n_output, order)
            % Returns the symbolic expression for the desired outputs
            switch type
                case 'Constant'
                    n_param = 1;
                case 'Bezier'
                    n_param = order + 1;
                    assert(~isempty(order),...
                        'Must specify the order of the Bezier polynomials.');
                case 'CWF'
                    n_param = 5;
                case 'ECWF'
                    n_param = 7;
                case 'MinJerk'
                    n_param = 3;
                otherwise
                    error('Undefined function type for the desired output.');
                    
            end
            
            % construct the parameter set for the desired outputs
            a = ParamVariable(['a' obj.Name],[n_output,n_param]);   
            if strcmp(type, 'Bezier')
                yd = eval_math_fun('DesiredFunction',{str2mathstr(type),n_output,a, order});
            else
                yd = eval_math_fun('DesiredFunction',{str2mathstr(type),n_output,a});
            end
            
        end
    end
    
    methods
        % export symbolic functions
        export(obj, export_path, varargin);
        
        % configure symbolic expression
        configure(obj, load_path, varargin);
        
        % calculates the actual outputs
        varargout = calcActual(obj, x, dx, offset);
            
        % calculates the desired outputs
        varargout = calcDesired(obj, t, x, dx, a, p);
        
        % calculates the phase variable
        varargout = calcPhaseVariable(obj, t, x, dx, p);
        
        % enforce as NLP constraints
        nlp = imposeNLPConstraint(obj, nlp, ep, nzy, load_path);
        
        % save symbolic expressions
        saveExpression(obj, export_path, varargin);
    end
    
    
    % set functions
    methods 
        % OutputLabel
        function obj = setOutputLabel(obj, label)
            % sets the naming labels of outputs
            %
            % Parameters:
            % label: the cell array of labels @type cellstr
            
            if ischar(label), label = {label}; end
            
            validateattributes(label,{'cell'},...
                {'nonempty','numel',obj.Dimension,'row'},...
                'VirtualConstraint','Label');
            cellfun( @(x) validateattributes(...
                x, {'char'},{}), label);
            
            obj.OutputLabel = label;
        end
        
        % PhaseType
        function obj = setPhaseType(obj, type)
            % sets the type of the phase variable
            %
            % Parameters:
            % type: type of the phase variable @type char
            
            
            type = validatestring(type, {'StateBased','TimeBased'},...
                'VirtualConstraint','PhaseType');
            obj.PhaseType = type;
        end

        % DesiredType
        function obj = setDesiredType(obj, type, degree)
            % sets the function type of the desired outputs
            %
            % Parameters:
            % type: the function type @type char
            % degree: the degree of polynomials @type integer
            
            %             type = validatestring(type, ...
            %                 {'Bezier','CWF','ECWF','MinJerk','Constant'},...
            %                 'VirtualConstraint','DesiredType');
            obj.DesiredType = type;
            if strcmp(type,'Bezier')
                validateattributes(degree,{'double'},...
                    {'integer','positive','>',1,'scalar'},...
                    'VirtualConstraint','PolyDegree');
                obj.PolyDegree = degree;
                [yd, a] = obj.getDesiredOutput(type, obj.Dimension, degree);
            else
                [yd, a] = obj.getDesiredOutput(type, obj.Dimension);
            end
            
            obj.yd_ = yd;
            obj.OutputParams = a;
        end

        % RelativeDegree
        function obj = setRelativeDegree(obj, degree)
            % sets the relative degree of the virtual constraints
            % 
            % Parameters:
            % degree: relative degree of outputs @type integer
            
            validateattributes(degree, {'double'},...
                {'nonempty','scalar','positive','integer'},...
                'VirtualConstraint','RelativeDegree');
            obj.RelativeDegree = degree;
             
        end

        % Holonomic
        function obj = setHolonomic(obj, type)
            % sets the type of whether the virtual constraints are
            % holonomic or nonholonomic
            % 
            % Parameters:
            % type: true for holonomic, false for nonholonomic
            % @type logical
            
            validateattributes(type, {'logical'},...
                {'nonempty','scalar'},...
                'VirtualConstraint','Holonomic');
            obj.IsHolonomic = type;
            
            if ~type % nonholonomic
                if strcmp(obj.Model.Type,'FirstOrder')
                    error('It is invalid to define non-holonomic virtual constraints for a first-order system.');
                end
            end
        end
        
        % Phase variale
        function obj = setPhaseVariable(obj, tau, p)
            % sets the symbolic expression of the state-based timing phase
            % variable 
            %
            % Parameters: 
            % tau: the phase variable @type SymExpression
            % p: the parameters of tau @type SymVariable
           
            validateattributes(tau,{'SymExpression'},...
                {'nonempty','scalar'},...
                'VirtualConstraint','PhaseVariable');
            
            obj.tau_ = tau;
            if nargin > 2
                validateattributes(p, {'SymVariable'},...
                    {'nonempty'},...
                    'VirtualConstraint', 'PhaseParams');
                obj.hasPhaseParam = true;
                obj.PhaseParams   = p;
            end
            
        end
    end
    
    methods (Static)
        % Name
        function name = validateName(name)
            validateattributes(name, {'char'},...
                {'nonempty','scalartext'},...
                'VirtualConstraint','Name');
            
            assert(isempty(regexp(name, '\W', 'once')) || ~isempty(regexp(name, '\$', 'once')),...
                'VirtualConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain special characters.');
            
            assert(isempty(regexp(name, '_', 'once')),...
                'VirtualConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain ''_''.');
            
        end
    end
end

