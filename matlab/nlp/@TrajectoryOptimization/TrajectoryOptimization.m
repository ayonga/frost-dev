classdef TrajectoryOptimization < NonlinearProgram
    % TrajectoryOptimization defines a particular type of nonlinear
    % programing problem --- trajectory optimization problem 
    % 
    % @see NonlinearProgram, HybridSystem
    %
    % @author ayonga @date 2016-10-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    %% Protected properties
    properties (SetAccess = protected)
        
        
        % The number of discrete nodes　along the trajectory
        %
        % @type integer
        NumNode
        
        % A table of NLP decision variables. The row determines the
        % identity of the variable, and the column determines at which node
        % the variable is defined.
        %
        % @type table
        OptVarTable
        
        % A table of NLP constraints. The row determines the identity of
        % the constraint, and the column determines at which node the
        % constraint is defined.
        %
        % @type table
        ConstrTable
        
        % A table of cost functions. The row determines the identity of the
        % function, and the column determines at which node the variable is
        % defined.
        %
        % @attention We assume the cost functioin (or objective) of a NLP
        % is the sum of these cost functions.
        %
        % @type table
        CostTable
        
        % The dynamical system plant of the interest
        %
        % @type DynamicalSystem
        Plant
        


        
    end
    
    
    %% Public methods
    methods (Access = public)
        
        function obj = TrajectoryOptimization(name, plant, num_grid, bounds, options)
            % The constructor function
            %
            % Parameters:
            % name: the name of the problem @type char
            % plant: the dynamical system plant @type DynamicalSystem
            % num_grid: the number of grids along the trajectory 
            % @type integerConstantTimeHorizon
            % bounds: a structed data stores the boundary information of the
            % NLP variables @type struct
            % varargin: user-defined options for the problem @type varargin
            
            arguments
                name char {mustBeTextScalar}
                plant DynamicalSystem
                num_grid double {mustBeInteger,mustBeNonnegative,mustBeScalarOrEmpty} = 10
                bounds struct = struct()
                options.DerivativeLevel {mustBeMember(options.DerivativeLevel, [0,1,2])} = 1
                options.EqualityConstraintBoundary double {mustBeNonnegative} = 0
                options.StackVariable logical = true
                options.CollocationScheme char {mustBeMember(options.CollocationScheme, {'HermiteSimpson','Trapezoidal','PseudoSpectral'})} = 'HermiteSimpson'
                options.DistributeParameters logical = false
                options.DistributeTimeVariable logical = false
                options.ConstantTimeHorizon (2,1) double {mustBeReal} = nan(2,1)
                options.LoadPath char = ''
                options.SkipConfigure logical = false
            end
            
            % call superclass constructor
            sup_opts = struct('DerivativeLevel', options.DerivativeLevel, ...
                'EqualityConstraintBoundary', options.EqualityConstraintBoundary,...
                'StackVariable',options.StackVariable);
            sup_opts_cell = namedargs2cell(sup_opts);
            obj = obj@NonlinearProgram(name, sup_opts_cell{:});
            
            if nargin == 0
                return;
            end
            
            
            % The dynamical system of interest
            obj.Plant = plant;
            
            if ~isnan(options.ConstantTimeHorizon)
                assert(options.ConstantTimeHorizon(1) < options.ConstantTimeHorizon(2), 'The time horizon must be an increasing order');
                assert(options.ConstantTimeHorizon(1) > 0, 'The time horizon must be positive');
            end
            obj = obj.setOption(options);
            
                   
            
            % check the problem setup
            
            
            
            
            
            
            
            % the default number of grids
            if ~isempty(num_grid)
                N = num_grid;
            end
            % determine actual number of nodes based on the different
            % collocation scheme
            switch obj.Options.CollocationScheme
                case 'HermiteSimpson'
                    n_node = N*2 + 1;
                case 'Trapezoidal'
                    n_node = N + 1;
                case 'PseudoSpectral'
                    n_node = N + 1;
            end
            obj.NumNode = n_node;
            
            % initialize the variable, constraints and cost function table
            col_names = cellfun(@(x)['node',num2str(x)], num2cell(1:n_node),...
                'UniformOutput',false);


            obj.OptVarTable = cell2table(cell(n_node,0),...
                'RowNames',col_names);
            obj.ConstrTable = cell2table(cell(n_node,0),...
                'RowNames',col_names);
            obj.CostTable   = cell2table(cell(n_node,0),...
                'RowNames',col_names);
            
            if ~options.SkipConfigure
                obj = configure(obj, bounds);
            end
        end
        
        
        
        
        
        
        
       
    end
    
    %% methods defined in external files
    methods
        
        [obj] = update(obj);
        
        obj = configure(obj, bounds, varargin);
        
        compileConstraint(obj, constr, export_path, exclude, varargin);
        
        compileObjective(obj, cost, export_path, exclude, varargin);
        
        %% functions related to NLP variables
        
        obj = addVariable(obj, nodes, varargin);
        
        obj = removeVariable(obj, label);
        
        obj = addInputVariable(obj, bounds);
                
        obj = addParamVariable(obj, bounds);
        
        obj = addStateVariable(obj, bounds);
        
        obj = addTimeVariable(obj, bounds);
        
        obj = updateVariableProp(obj, label, node, varargin);
        
        obj = configureVariables(obj, bounds);
        
        obj = configureConstraints(obj, bounds);
        
        obj = updateVariableBounds(obj, bounds);
        
        obj = updateConstraintBounds(obj, varargin)
        %% functions related to NLP constraints
        
        fcstr = directCollocation(obj, name, x, dx);
        
        obj = addConstraint(obj, label, nodes, cstr_array);
        
        obj = addCollocationConstraint(obj);
        
        

        obj = addNodeConstraint(obj, func, deps, nodes, lb, ub, type, auxdata);
                
        obj = updateConstrProp(obj, label, node, varargin);
        
        obj = removeConstraint(obj, label);
        
        %% functions related to NLP cost functions        
        
        obj = addCost(obj, label, nodes, cost_array);
        
        obj = addRunningCost(obj, func, deps, auxdata, load_path);
        
        obj = addNodeCost(obj, func, deps, node, auxdata);
        
        obj = updateCostProp(obj, label, node, varargin);
                
        obj = removeCost(obj, label);
        %% post-processing functions
        
        [yc, cl, cu] = checkConstraints(obj, x, tol, output_file, permission);
        
        [yc] = checkCosts(obj, x, output_file,permission);
        
        checkVariables(obj, x, tol, output_file, permission);
        
        [tspan, states, inputs, params] = exportSolution(obj, sol, t0);
    end
end

