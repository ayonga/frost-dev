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
        
        
        
        % The discrete phases of the hybrid trajectory optimization
        %
        % @type cell
        Phase
        
        % The rigid body model of the robot
        %
        % @type RigidBodyModel
        Model
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
        
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = HybridTrajectoryOptimization(varargin)
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
            default_opts.UseTimeBasedOutput = true;
            
                        
            % call superclass constructor
            obj = obj@NonlinearProgram(default_opts);           
            
            % if non-default options are specified, overwrite the default
            % options.
            obj.Options = setOption(obj, varargin{:});
            
            
        end
        
        
        
%         DynamicsConstraints
%         CollocationConstraints
%         DomainConstraints
%         GuardConstraints
%         JumpConstraints
%         PathConstraints
%         TerminalConstraints
        
        
        
        
        
       
    end
    
    %% methods defined in external files
    methods
        vars = createVariableArray(obj, nodes, varargin);
        
        obj = addAuxilaryVariable(obj, phase, nodes, varargin);
        
        obj = addControlVariable(obj, phase, model);
        
        obj = addGuardVariable(obj, phase, lb, ub, x0);
        
        obj = addParamVariable(obj, phase, lb, ub, x0);
        
        obj = addStateVariable(obj, phase, model);
        
        obj = addTimeVariable(obj, phase, lb, ub, x0);
    end
end

