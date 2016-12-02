classdef HybridTrajectoryOptimization < NonlinearProgram
    % HybridTrajectoryOptimization defines a particular type of nonlinear
    % programing problem --- trajectory optimization problem for a hybrid
    % dynamical system.
    % 
    % @see NonlinearProgram, HybridDynamicalSystem
    %
    % @author Ayonga Hereid @date 2016-10-26
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
    properties (Access = protected)
        
        phase
        
        meshes
        
        plant
        
        time
        
        states
        
        controls
        
        params
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
        
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = HybridTrajectoryOptimization(plant, options)
            % The constructor function
                        
            obj = obj@NonlinearProgram();
            
            % check the type of the plant
            assert(isa(plant, 'HybridDynamicalSystem'),...
                'HybridTrajectoryOptimization:invalidPlant',...
                'The plant must be an object of HybridDynamicalSystem catagory.\n');
            
            obj.plant = plant;
            
            obj.options.collocation_method = 'Hermite-Simpson';
            obj.options.distribute_params = true;
            
            % overwrite non-default options
            if nargin > 1
                obj.options = struct_overlay(obj.options, options);
            end
            
            % load default meshes (10 collocation nodes) if not specified
            % explicitly
            if ~isfield(obj.options, 'meshes')
                obj.options.meshes = 10*ones(1, obj.num_phases);
            end
            
            
            addTimeVariable();
            addStateVariable();
            addControlVariable();
            addParameter();
            
            addDynamicsConstraint();
            addCollocationConstraint();
            addPatchConstraint();
            addTerminalConstraint();
            
            addRunningCost();
            addTerminalCost();
        end
        
        
        function obj = addTimeVariable(obj)
            %
            
            
            
        end
        
        function obj = addStateVariable(obj, plant)
            
            
        end
    
        
        
    end
    
end

