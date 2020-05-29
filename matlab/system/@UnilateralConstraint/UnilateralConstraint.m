classdef UnilateralConstraint < handle
    % UnilateralConstraint represents a scalar or vector inequality
    % constraints should be imposed on the continuous dynamical systems
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
    
    
    
    
    
    methods
        
        function obj = UnilateralConstraint(model, h, name, deps, varargin)
            % The class constructor function
            %
            % Parameters:
            % model: the dynamical system model in which the virtual
            % constraints are defined @type DynamicalSystem
            % h: the symbolic expression of the constraints
            % name: the name of the virtual constraints @type char
            % deps: the dependent variables (could be states or inputs) @type
            % cellstr
            % @type SymExpression
            % varargin: optional parameters. In details
            %  AuxData: 
            %  ConstrLabel: 
            
            
            
            if nargin == 0
                return;
            end
            
            % validate (model) argument
            validateattributes(model, {'DynamicalSystem'},...
                {'scalar'},...
                'UnilateralConstraint','model');
            
            
            
            % validates (name) argument
            validateName(obj, name);
            obj.Name = name;
            
            
            % validate (ya) argument
            validateattributes(h,{'SymExpression'},...
                {'nonempty','vector'},...
                'UnilateralConstraint','h');            
            if isrow(h) && ~iscolumn(h) % convert to column vector if it is a row vector
                h = vertcat(h(:));
            end
            dim = length(h);
            obj.Dimension = dim;
            
            
            % parse the input options
            args = struct(varargin{:});
            assert(isscalar(args),...
                'The values of optional properties are must be scalar data.');
            
            % validate and assign the label
            if isfield(args, 'ConstrLabel')
                obj.setConstrLabel(args.ConstrLabel);
            end
            
            if isfield(args, 'AuxData')
                auxdata = args.AuxData;
            else
                auxdata = [];
            end
            
            %% set the unilateral constraints            
            if ~iscell(deps), deps = {deps}; end
            n_deps = length(deps);
            
            % get the variable group of each dependent variable
            var_group = cellfun(@(x)model.validateVarName(x), deps, 'UniformOutput', false);
            vars = cell(1,n_deps);
            
            % assume it is not input-dependent
            input_dep = false;
            for i=1:n_deps
                tmp = var_group{i};
                % check if it is input-dependent
                if strcmp(tmp{1},'Inputs')
                    input_dep = true;
                    vars{i} = model.(tmp{1}).(tmp{2}).(deps{i});
                else
                    vars{i} = model.(tmp{1}).(deps{i});
                end
            end
            obj.InputDependent = input_dep;
            
            if isa(h, 'SymFunction')
                % validate the dependent variables
                assert(length(h.Vars)==n_deps,...
                    ['The constraint SymFunction (h) must have the same',...
                    'number of dependent variables as specified in the argument (deps).']);
                for i=1:n_deps
                    assert(h.Vars{i} == vars{i},...
                        'The %d-th dependent variable must be the same as the variable %s.',i,deps{i});
                end
                obj.h_ = h;
                obj.DepLists = deps;
                
                
                if ~isempty(h.Params)
                    if isempty(auxdata)
                        error('The constraint function requires auxilary constant parameters.');
                    else
                        if ~iscell(auxdata), auxdata = {auxdata}; end
                        assert(length(h.Params) == length(auxdata),...
                            'The number of required auxilaray data (%d) and the provided auxilary data (%d) does not match.\n',...
                            length(h.Params),length(auxdata));
                        for i=1:numel(auxdata)
                            assert(numel(auxdata{i})== prod(size(h.Params{i})),...
                                'The length %d-th auxiliary parameters variable does not match the function definition.',i); %#ok<PSIZE>
                        end
                        
                        obj.AuxData = auxdata;
                    end
                    
                else
                    obj.AuxData = [];
                end
                
                
            elseif isa(h, 'SymExpression')
                % create a SymFunction object if the input is a SymExpression
                
                obj.h_ = SymFunction(['u_' name '_' model.Name], h, vars);
                obj.DepLists = deps;
                if ~isempty(auxdata)
                    error('If the constraint depends on auxilary constant parameters, please provide it as a SymFunction object directly.');
                end
                obj.AuxData = [];
            else
                error('The constraint expression must be given as an object of SymExpression or SymFunction.');
            end
            
        end
        
        
        
    end
    
    
    % properties determined internally
    properties (SetAccess=protected, GetAccess=public)
        % The dimension of the virtual constraints
        %
        % @type integer
        Dimension
        
        % An indicator whether the unilateral constraints depend on the
        % input variables of the dynamical system. If the constraints are
        % input-dependent, then it will requires to execute the
        % calcDynamics function to compute the required input signals.
        %
        % @type logical
        InputDependent
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
        
        
        % The name list of dependent variables in the associated dynamical
        % system model
        %
        % @type cellstr
        DepLists
        
        % The list of auxiliary data to be used to call the function
        %
        % @type cell
        AuxData
        
    end

    
    properties (Dependent)
        % The holonomic constraint expression
        %
        % @type SymFunction
        ConstrExpr
        
        
        
    end
    
    methods 
        function cstr = get.ConstrExpr(obj)
            cstr = obj.h_;
        end
        
        
    end
    
    
    properties (Access = protected)
        
        
        % The holonomic constraint expression
        %
        % @type SymFunction
        h_
        
    end
            
    
    
    methods
        function export(obj, export_path, varargin)
            % export the symbolic expressions of the constraints and
            % compile as MEX files.
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
            
        end
        
        function nlp = imposeNLPConstraint(obj, nlp)
            % impose holonomic objaints as NLP objaints in the trajectory
            % optimization problem 'nlp' of the dynamical system
            %
            %
            % Parameters:
            % nlp: the trajectory optimization NLP @type TrajectoryOptimization
            
            
            if ~isempty(obj.AuxData)
                nlp = addNodeConstraint(nlp, obj.h_, obj.DepLists, 'all',...
                    0, inf, 'Nonlinear', obj.AuxData);
            else
                nlp = addNodeConstraint(nlp, obj.h_, obj.DepLists, 'all',...
                    0, inf, 'Nonlinear');
            end
            
            
        end
        
        function f = calcConstraint(obj, varargin)
            % calculate the unilateral constraints
            %
            % Parameters:
            % varargin: input variable depends on the object
            %
            % Return values:
            % f: the value of the unilateral constraints
            if isempty(obj.AuxData)
                f = feval(obj.h_.Name, varargin{:});
            else
                f = feval(obj.h_.Name, varargin{:}, obj.AuxData{:});
            end
        end
        
        
    end
    
    
    % set functions
    methods 
        
        
        
        % OutputLabel
        function obj = setConstrLabel(obj, label)
            % sets the naming labels of outputs
            %
            % Parameters:
            % label: the cell array of labels @type cellstr
            
            validateattributes(label,{'cell'},...
                {'nonempty','numel',obj.Dimension,'row'},...
                'UnilateralConstraint','ConstrLabel');
            cellfun( @(x) validateattributes(...
                x, {'char'},{}), label);
            
            obj.ConstrLabel = label;
        end
        
        
        % Name
        function name = validateName(~, name)
            validateattributes(name, {'char'},...
                {'nonempty','scalartext'},...
                'UnilateralConstraint','Name');
            
            assert(isempty(regexp(name, '\W', 'once')) || ~isempty(regexp(name, '\$', 'once')),...
                'UnilateralConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain special characters.');
            
            assert(isempty(regexp(name, '_', 'once')),...
                'UnilateralConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain ''_''.');
            
        end
    end
end

