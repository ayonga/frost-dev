classdef UnilateralConstraint < handle
    % UnilateralConstraint represents a scalar or vector inequality
    % constraints should be imposed on the continuous dynamical systems
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
    
    
    
    
    
    methods
        
        function obj = UnilateralConstraint(func, model, options)
            % The class constructor function
            %
            % Parameters:
            % name: the name of the virtual constraints @type char
            % model: the dynamical system model in which the unilateral
            % constraints are defined @type DynamicalSystem
            % expr: the symbolic expression of the constraints
            % deps (repeatable): the dependent variables @type BoundedVariable
            % @type SymExpression
            % options: optional parameters. In details
            %  AuxData: 
            %  ConstrLabel: 
            
            arguments
                func SymFunction
                model ContinuousDynamics {mustBeScalarOrEmpty}      
                options.AuxData (:,1) cell
                options.ConstrLabel (:,1) cell
            end
                       
            
            
            obj.Name = func.Name;
            obj.Dimension = length(func);
            
            obj.h_ = func;
            
            deps = func.Vars;
            % get the variable group of each dependent variable
            cellfun(@(x)model.validateVarName(x.Name), deps, 'UniformOutput', false);
            
            
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
            
            
            
            obj.DepLists = cellfun(@(x)x.Name, deps, 'UniformOutput', false);
            
                
                
            
            % validate and assign the label
            if isfield(options, 'ConstrLabel')
                obj.setConstrLabel(options.ConstrLabel);
            end
        end
        
        
        
    end
    
    
    % properties determined internally
    properties (SetAccess=protected, GetAccess=public)
        % The dimension of the virtual constraints
        %
        % @type integer
        Dimension
        
    end
    
    % properties must be determined by the users
    properties (SetAccess=protected, GetAccess=public)
        % The name of the virtual constraints 
        %
        % @type char
        Name
        
        
        % The label of the constraint
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
            
            arguments
                obj UnilateralConstraint
                export_path char {mustBeFolder}
            end
            arguments (Repeating)
                varargin
            end
            
            export(obj.h_,export_path, varargin{:});
            
        end
        
        function nlp = imposeNLPConstraint(obj, nlp, varargin)
            % impose holonomic objaints as NLP objaints in the trajectory
            % optimization problem 'nlp' of the dynamical system
            %
            %
            % Parameters:
            % nlp: the trajectory optimization NLP @type TrajectoryOptimization
            arguments
                obj UnilateralConstraint
                nlp TrajectoryOptimization
            end
            arguments (Repeating)
                varargin
            end
            
            if ~isempty(obj.AuxData)
                nlp = addNodeConstraint(nlp, 'all', obj.h_, obj.DepLists, ...
                    0, inf, obj.AuxData);
            else
                nlp = addNodeConstraint(nlp, 'all', obj.h_, obj.DepLists, ...
                    0, inf);
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
                {'nonempty','numel',obj.Dimension,'column'},...
                'UnilateralConstraint','ConstrLabel');
            
            cellfun( @(x) validateattributes(...
                x, {'char'},{}), label);
            
           
            
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
                'UnilateralConstraint:invalidSymbol', ...
                'Invalid symbol string, can NOT contain ''_''.');
            
        end
    end
end

