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
    
    %% Public properties
    properties (Access = public)
    end
    
    properties (Hidden, Constant)
        % The default number of collocation grids
        %
        % @type double
        DefaultNumberOfGrid = 10;
    end
    
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
        
        function obj = TrajectoryOptimization(name, plant, num_grid, varargin)
            % The constructor function
            %
            % Parameters:
            % name: the name of the problem @type char
            % plant: the dynamical system plant @type DynamicalSystem
            % num_grid: the number of grids along the trajectory 
            % @type integer
            % varargin: user-defined options for the problem @type varargin
            
            
            
            % call superclass constructor
            obj = obj@NonlinearProgram(name);
            
            % check the type of the plant
            assert(isa(plant, 'DynamicalSystem'),...
                'TrajectoryOptimization:InvalidPlant',...
                'The plant must be an object of ''DynamicalSystem'' class or its subclasses.\n');
            % The dynamical system of interest            
            obj.Plant = plant;
            
             
            
            ip = inputParser;
            ip.addParameter('CollocationScheme','HermiteSimpson',@(x)validatestring(x,{'HermiteSimpson','Trapzoidal','PseudoSpectral'}));
            ip.addParameter('DistributeParameters',true,@(x) isequal(x,true) || isequal(x,false));
            ip.addParameter('DistributeTimeVariable',true,@(x) isequal(x,true) || isequal(x,false));
            ip.addParameter('ConstantTimeHorizon',NaN,@(x) isreal(x) && x>=0);
            ip.addParameter('IsPeriodic',false,@(x) isequal(x,true) || isequal(x,false));
            ip.addParameter('DerivativeLevel',1,@(x) x==0 || x==1 || x==2);
            ip.addParameter('EqualityConstraintBoundary',0,@(x) isreal(x) && x >= 0);
            ip.parse(varargin{:});
            obj.Options = ip.Results;
            % default options
            %             obj.Options.CollocationScheme       = 'HermiteSimpson';
            %             obj.Options.DistributeParameters    = false;
            %             obj.Options.DistributeTimeVariable  = false;
            %             obj.Options.ConstantTimeHorizon     = NaN;
            %             obj.Options.IsPeriodic              = false;
            
                   
            % the default number of grids
            N = TrajectoryOptimization.DefaultNumberOfGrid;
            if nargin > 2
                if ~isempty(num_grid)
                    % if non-default number of grids is specified, use that
                    assert(isscalar(num_grid) && isreal(num_grid) && rem(num_grid,1) == 0 && num_grid > 0,...
                        'The second argument must be a positive integer');
                    N = num_grid;
                end
            end
            % check the problem setup
            
            
            
            
            
            
            
            
            % determine actual number of nodes based on the different
            % collocation scheme
            switch obj.Options.CollocationScheme
                case 'HermiteSimpson'
                    obj.NumNode = N*2 + 1;
                case 'Trapzoidal'
                    obj.NumNode = N + 1;
                case 'PseudoSpectral'
                    obj.NumNode = N + 1;
                otherwise
                    error('TrajectoryOptimization:InvalidScheme', ...
                        ['Unsupported collocation scheme. It must be one of the following: \n',...
                        '%s, %s, %s \n'], 'HermiteSimpson', 'Trapzoidal', 'PseudoSpectral');
            end
                
            
            % initialize the variable, constraints and cost function table
            col_names = cellfun(@(x)['node',num2str(x)], num2cell(1:obj.NumNode),...
                'UniformOutput',false);


            obj.OptVarTable = cell2table(cell(obj.NumNode,0),...
                'RowNames',col_names);
            obj.ConstrTable = cell2table(cell(obj.NumNode,0),...
                'RowNames',col_names);
            obj.CostTable   = cell2table(cell(obj.NumNode,0),...
                'RowNames',col_names);
            
            

            
            
        end
        
        
        
        
        
        
        
       
    end
    
    %% methods defined in external files
    methods
        
        % functions related to NLP variables
        obj = addVariable(obj, label, nodes, varargin);
        
        obj = addInputVariable(obj, bounds);
                
        obj = addParamVariable(obj, bounds);
        
        obj = addStateVariable(obj, bounds);
        
        obj = addTimeVariable(obj, bounds);
        
        
        % functions related to NLP constraints
        
        obj = addConstraint(obj, label, nodes, cstr_array);
        
        obj = addCollocationConstraint(obj);
        
        obj = addDynamicsConstraint(obj);  

        obj = addOutputRD2Constraint(obj,params,ddx);
        
        obj = addNodeConstraint(obj, func, deps, nodes, lb, ub, type, auxdata);
        % functions related to NLP cost functions        
        
        obj = addCost(obj, label, nodes, cost_array);
        
        obj = addRunningCost(obj, func, deps, auxdata);
        
        obj = addNodeCost(obj, func, deps, node, auxdata);
        
        obj = updateCostProp(obj, label, node, varargin);
        
        obj = updateConstrProp(obj, label, node, varargin);
        
        obj = updateVariableProp(obj, label, node, varargin);
        % post-processing functions
        [yc, cl, cu] = checkConstraints(obj, x);
        
        [xc, lb, ub] = checkVariables(obj, x);
        
        [yc] = checkCosts(obj, x);
        
        [tspan, states, inputs, params] = exportSolution(obj, sol, t0)
    end
end

