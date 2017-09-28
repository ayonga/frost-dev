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
        
        % An indicator that shows there is an offset in the actual outputs
        %
        % @type logical
        hasOffset = false;
        
        % The symbolic representation of parameter sets of the desired
        % outputs
        % 
        % @type SymVariable
        OutputParams
        
        % The symbolic representation of offset of the actual outputs: ya =
        % ya_orig + offset_params
        % 
        % @type SymVariable
        OffsetParams
    end
    
    % properties must be determined by the users
    properties (SetAccess=protected, GetAccess=public)
        % The name of the virtual constraints 
        %
        % @type char
        Name
        
        
        % The symbolic representation of parameters of the phase variable
        %
        % @type SymVariable
        PhaseParams
        
        
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
        Holonomic

        
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
        
        % The name of the offset parameter variable
        % 
        % @type char
        OffsetParamName
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
        function name = get.OffsetParamName(obj)
            name = ['c' obj.Name];
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
        
        % An indicator that shows there is a parameter variable for phase
        %
        % @type logical
        hasPhaseParam = false;
        
        
        
        
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
        
        function obj = VirtualConstraint(model, ya, name, varargin)
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
            
            
            
            if nargin == 0
                return;
            end
            
            % validate (model) argument
            validateattributes(model, {'DynamicalSystem'},...
                {'scalar'},...
                'VirtualConstraint','model');
            obj.Model = model;
            
            % validates (name) argument
            validateName(obj, name);
            obj.Name = name;
            
            args = struct(varargin{:});
            assert(isscalar(args),...
                'The values of optional properties are must be scalar data.');
            
            if ~isempty(ya)
                % validate (ya) argument
                validateattributes(ya,{'SymExpression'},...
                    {'nonempty','vector'},...
                    'VirtualConstraint','ya');
                if isrow(ya) % convert to column vector if it is a row vector
                    ya = vertcat(ya(:));
                end
            elseif isfield(args, 'LoadPath')
                ya = SymExpression([]);
                ya = load(ya, args.LoadPath, ['ya_' obj.Name '_' model.Name]);
            else
                error(['Unable to create the VirtualConstraint object. ',...
                    'Either the expression is empty or the load path is not specified.'],...
                    'VirtualConstraint');
            end
            
            
            
            
            obj.Dimension = length(ya);
            if isfield(args, 'HasOffset')
                if args.HasOffset
                    obj.hasOffset = true;
                    offset = SymVariable(['c' obj.Name],[obj.Dimension,1]);
                    obj.ya_ = ya + offset;
                    obj.OffsetParams = offset;
                else
                    obj.ya_ = ya;
                end
            else
                obj.ya_ = ya;
            end
            
            
            
            % validate and assign the desired outputs
            
            
            if isfield(args, 'DesiredType')
                if isfield(args, 'PolyDegree')
                    obj.setDesiredType(args.DesiredType, args.PolyDegree);
                else
                    obj.setDesiredType(args.DesiredType);
                end
            else
                error('The desired output function type (DesiredType) must be given.');
            end
            
            if isfield(args, 'OutputLabel')
                obj.setOutputLabel(args.OutputLabel);
            end
            
            if isfield(args, 'RelativeDegree')
                obj.setRelativeDegree(args.RelativeDegree);
            else
                error('The relative degree of the virtual constraints (RelativeDegree) must be defined.');
            end
            
            if isfield(args, 'PhaseType')
                obj.setPhaseType(args.PhaseType);
            else
                error('The type of phase variable (PhaseType) must be given.');
            end
            
            if isfield(args, 'PhaseVariable')
                if isfield(args, 'PhaseParams')
                    obj.setPhaseVariable(args.PhaseVariable, args.PhaseParams);
                else
                    obj.setPhaseVariable(args.PhaseVariable);
                end
            end
            
            
            if isfield(args, 'Holonomic')
                obj.setHolonomic(args.Holonomic);
            else
                error('Please determine whether the virtual constraint is holonomic (Holonomic) or not.');
            end
            
            if isfield(args, 'LoadPath') && ~isempty(args.LoadPath)
                load_path = args.LoadPath;
            else
                load_path = [];
            end
            
            if isfield(args, 'ExtraConfig')
                obj.configure(load_path, args.ExtraConfig{:});
            else
                obj.configure(load_path);
            end
            
            
            
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
            a = SymVariable(['a' obj.Name],[n_output,n_param]);   
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
            
            type = validatestring(type, ...
                {'Bezier','CWF','ECWF','MinJerk','Constant'},...
                'VirtualConstraint','DesiredType');
            obj.DesiredType = type;
            if nargin > 2
                validateattributes(degree,{'double'},...
                    {'integer','positive','>',2,'scalar'},...
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
            obj.Holonomic = type;
            
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
        
        % Name
        function name = validateName(~, name)
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

