classdef HybridTrajectoryOptimization < NonlinearProgram
    % HybridTrajectoryOptimization defines a particular type of nonlinear
    % programing problem --- trajectory optimization problem for a hybrid
    % dynamical system.
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
    
    %% Protected properties
    properties (SetAccess = protected)
        % A structure of which each sub-field provides the interface to
        % external functions for NLP constraints or cost function.
        %
        % @note Typically, we will use SymFunction to construct such an object
        % for a function. However, users could also employ other class or
        % structure for their own custom functions. One requirement of such
        % an object is that it must have a field called ''Funcs'' to
        % provides the external function name (or function handles). 
        %
        % @note To add a new function object, create a new field in this
        % variable.        
        % 
        % @see SymFunction
        %
        % Required fields of Funcs:
        % Model: model specific functions @type struct
        % Phase: phase specific functions, each cell contains functions for
        % a particular phase @type cell
        % Generic: generic functions @type struct
        %
        % @type struct        
        Funcs
        
        
        % The discrete phases of the hybrid trajectory optimization
        %
        % @type cell
        Phase
        
        
        % The rigid body model of interest
        %
        % @type RigidBodyModel
        Model
        
        % The directed graph of the hybrid sytem model to be optimized
        %
        % @type digraph
        Gamma
        
        % The hybrid system to be optimized
        %
        % @type HybridSystem
        % Plant
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
        
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = HybridTrajectoryOptimization(plant, varargin)
            % The constructor function
            %
            % Parameters:
            % plant: the hybrid system plant @type HybridSystem
            % options: user-defined options for the problem @type struct
            
            
            
            % default options
            default_opts.CollocationScheme = 'HermiteSimpson';
            default_opts.DistributeParamWeights = false;
            default_opts.NodeDistributionScheme = 'Uniform';
            default_opts.EnableVirtualConstraint = true;
            default_opts.UseTimeBasedOutput = false;
            default_opts.DefaultNumberOfGrids = 10;
            default_opts.ZeroVelocityOutputError = false;
            default_opts.UseSameParameters = true;
            default_opts.EnforceForceConstraint = false;
            % call superclass constructor
            obj = obj@NonlinearProgram(default_opts);           
            
            % if non-default options are specified, overwrite the default
            % options.
            obj.Options = setOption(obj, varargin{:});
            
            % check the type of the plant
            assert(isa(plant, 'HybridSystem'),...
                'HybridTrajectoryOptimization:invalidPlant',...
                'The plant must be an object of HybridSystem catagory.\n');
            
            obj.Gamma = plant.Gamma;
            obj.Model = plant.Model;
                        
            n_vertex = height(plant.Gamma.Nodes);
            obj.Phase = cell(n_vertex,1);
            
            obj.Funcs = struct;
            obj.Funcs.Model = struct;
            obj.Funcs.Phase = cell(n_vertex, 1);
            obj.Funcs.Generic = struct;
        end
        
        
        
        
        
        
        
       
    end
    
    %% methods defined in external files
    methods
        obj = initializeNLP(obj, options);
        
        obj = addAuxilaryVariable(obj, phase, nodes, varargin);
        
        obj = addControlVariable(obj, phase);
        
        obj = addGuardVariable(obj, phase, lb, ub, x0);
        
        obj = addParamVariable(obj, phase, lb, ub, x0);
        
        obj = addStateVariable(obj, phase);
        
        obj = addTimeVariable(obj, phase, lb, ub, x0);
        
        obj = configureNLP(obj, options);
        
        obj = genericSymFunctions(obj);
        
        
        obj = compileSymFunction(obj, field, phase, export_path);
        
        obj = addCollocationConstraint(obj, phase);
        
        obj = addDomainConstraint(obj, phase);
        
        obj = addDynamicsConstraint(obj, phase);
        
        obj = addJumpConstraint(obj, phase);

        obj = addOutputConstraint(obj, phase)
        
        obj = addParamConstraint(obj, phase);
        
        obj = addAuxilaryConstraint(obj, phase, nodes, deps, varargin);
        
        obj = addRunningCost(obj, phase, func);
        
        obj = addTerminalCost(obj, phase, name, func, deps, nodes, auxdata)
        
        phase_idx = getPhaseIndex(obj, phase);
        
        [yc, cl, cu] = checkConstraints(obj, x);
        
        [xc, lb, ub] = checkVariables(obj, x);
        
        [calcs, params] = exportSolution(obj, sol);
    end
end

