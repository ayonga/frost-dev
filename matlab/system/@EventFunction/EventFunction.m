classdef EventFunction < handle
    % EventFunction represents a scalar event function that triggers a
    % discrete dynamics of the system
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
    
    
    properties
        % a callback function for custom event function
        CustomEventFunc
        
        % a callback function for custom nlp constraints function
        CustomNLPConstraint
    end
    
    
    methods
        
        function obj = EventFunction(func, model, options)
            % The class constructor function
            %
            % event = EventFunction('impact',robot, h_nsf,...
            % robot.States.q,'Parameters',{{hd,0},{p,3}})
            %
            % Parameters:
            % name: the name of the event @type char
            % model: the dynamical system model in which the event are defined @type ContinuousDynamics
            % expr: the symbolic expression of the event
            % deps (repeatable): the dependent variables @type BoundedVariable
            % @type SymExpression
            % options: optional parameters. In details
            %  AuxData: 
            
            arguments                
                func (1,1) SymFunction
                model ContinuousDynamics
                options.AuxData (1,:) cell
            end
                                     
            obj.Name = func.Name;
            deps = func.Vars;
            obj.h_ = func;
            obj.DepLists = cellfun(@(x)x.Name, deps, 'UniformOutput', false);
                      
            % validate dependent variable if they are variables defined in
            % the model
            cellfun(@(x)obj.validateDepVariable(model,x), deps, 'UniformOutput', false);
            
            
                        
            if ~isempty(func.Params)
                if ~isfield(options, 'AuxData')
                    error('The constraint function requires auxilary constant parameters.');
                else
                    auxdata = options.AuxData;
                    assert(length(func.Params) == length(auxdata),...
                        'The number of required auxilaray data (%d) and the provided auxilary data (%d) does not match.\n',...
                        length(func.Params),length(auxdata));
                    for i=1:numel(auxdata)
                        assert(numel(auxdata{i})== prod(size(func.Params{i})),...
                            'The length %d-th auxiliary parameters variable does not match the function definition.',i); %#ok<PSIZE>
                    end
                    obj.AuxData = auxdata;
                end
            end
            
        end
        
        
        
    end
    
    
    
    % properties must be determined by the users
    properties (SetAccess=protected, GetAccess=public)
        % The name of the virtual constraints 
        %
        % @type char
        Name
        
        % The name list of dependent variables in the associated dynamical
        % system model
        %
        % @type cellstr
        DepLists
        
        % The list of auxiliary data to be used to call the function
        %
        % @type cell
        AuxData
        
        
        % Determine whether the event depends on any system inputs (e.g.,
        % constraint wrenches)
        %
        % type logical
        IsInputDependent logical = false
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
            
            arguments
                obj EventFunction
                export_path char {mustBeFolder}
            end
            arguments (Repeating)
                varargin
            end
            
            export(obj.h_,export_path, varargin{:});
            
        end
        
        function saveExpression(obj, export_path, varargin)
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
            
            arguments
                obj EventFunction
                export_path char {mustBeFolder}
            end
            arguments (Repeating)
                varargin
            end
            
            save(obj.h_,export_path, varargin{:});
            
        end
        
        function nlp = imposeNLPConstraint(obj, nlp, bounds)
            % impose holonomic objaints as NLP objaints in the trajectory
            % optimization problem 'nlp' of the dynamical system
            %
            %
            % Parameters:
            % nlp: the trajectory optimization NLP @type TrajectoryOptimization
            arguments
                obj EventFunction
                nlp TrajectoryOptimization
                bounds = []
            end
            
            if ~isempty(obj.AuxData)
                nlp = addNodeConstraint(nlp, 'all', obj.h_, obj.DepLists,...
                    0, inf, obj.AuxData);
                nlp = updateConstrProp(nlp, obj.h_.Name, 'last', ...
                    'lb',0,'ub',0,'AuxData',obj.AuxData);
            else
                nlp = addNodeConstraint(nlp, 'all', obj.h_, obj.DepLists, ...
                    0, inf);
                
                nlp = updateConstrProp(nlp, obj.h_.Name, 'last', ...
                    'lb',0,'ub',0);
            end
            
            
            if ~isempty(obj.CustomNLPConstraint)
                obj.CustomNLPConstraint(obj, nlp, bounds);
            end
            
        end
        
        function val = calcEvent(obj, model, t, t0)
            % calculate the unilateral constraints
            %
            % Parameters:
            % varargin: input variable depends on the object
            %
            % Return values:
            % f: the value of the unilateral constraints
            
                        
            dep_val = getValue(model,obj.DepLists);
            
            if isempty(obj.AuxData)
                val = feval(obj.h_.Name, dep_val{:});
            else
                val = feval(obj.h_.Name, dep_val{:}, obj.AuxData{:});
            end
            if ~isempty(obj.CustomEventFunc)
                val = obj.CustomEventFunc(obj, model, val, dep_val, t, t0);                
            end
        end
        
        function validateDepVariable(obj, model, dep) %#ok<*INUSL>            
            var_group = model.validateVarName(dep.Name);
            if isempty(var_group)
                error('The dependent variable (%s) must be a state/input/parameter variable of the system (%s).',deps.Name, model.Name);
            end
            if strcmp(var_group,'Inputs')
                obj.IsInputDependent = true;
            end
        end
        
        function set.CustomEventFunc(obj, func)              
            assert(isa(func,'function_handle'),'The callback function must be a function handle');
            assert(nargin(func) == 6, 'The callback function must have exactly four (event, model, val, dep_val, t, t0) inputs.');
            %             assert(nargout(func) >= 1, 'The callback function must have at least one (f) output');
            obj.CustomEventFunc = func;
        end       
        
        function set.CustomNLPConstraint(obj, func)              
            assert(isa(func,'function_handle'),'The callback function must be a function handle');
            assert(nargin(func) == 3, 'The callback function must have at exactly three (event, nlp, bounds) inputs.');
            %             assert(nargout(func) >= 1, 'The callback function must have at least one (f) output');
            obj.CustomNLPConstraint = func;
        end 
    end
    
    
    methods (Static)
        
        % Name
        function validateName(name)
            arguments
                name {mustBeValidVariableName}
            end
                        
            assert(isempty(regexp(name, '_', 'once')),...
                'UnilateralConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain ''_''.');
            
        end
    end
    
end

