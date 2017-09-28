classdef HybridTrajectoryOptimization < NonlinearProgram
    % HybridTrajectoryOptimization defines a particular type of nonlinear
    % programing problem --- trajectory optimization problem for a hybrid
    % dynamical system.
    % 
    % @see NonlinearProgram, HybridSystem, TrajectoryOptimization
    %
   
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
    properties (Access = private)
        % The directed graph of the hybrid system to be optimized
        % 
        % @type DirectedGraph
        Gamma
        
        % The variable indices of each phase
        %
        % @type matrix
        PhaseVarIndices
    end
    
    %% Protected properties
    properties 
        % The discrete phases of the hybrid trajectory optimization
        %
        % @type TrajectoryOptimization
        Phase
        
    end
    
    
    
    %% Public methods
    methods (Access = public)
        
        function obj = HybridTrajectoryOptimization(name, plant, num_grid, bounds, varargin)
            % The constructor function
            %
            % Parameters:
            % name: the name of the NLP @type char
            % plant: the hybrid system plant @type HybridSystem
            % num_grid: the number of grids along the trajectory 
            % @type integerConstantTimeHorizon
            % bounds: a structed data stores the boundary information of the
            % NLP variables @type struct
            % options: user-defined options for the problem @type struct
            
            if nargin > 0
                name = {name};
            else
                name = {};
            end
            
            % call superclass constructor
            obj = obj@NonlinearProgram(name{:});
            
            if nargin == 0
                return;
            end       
            
            
            
            % if non-default options are specified, overwrite the default
            % options.
            obj.setOption(varargin{:});
            
            % check the type of the plant
            validateattributes(plant,{'HybridSystem'},{},...
                'HybridTrajectoryOptimization','plant',2);
            
            % validate the plant being able to use for a hybrid trajectory
            % optimization
            validateGraph(obj, plant);
            
            % check if the graph is a simple directed cycle
            %             if ~isDirectedCycle(plant)
            %                 % reorder nodes with its topological order
            %                 g = reordernodes(plant.Gamma, toposort(plant.Gamma,'Order','Stable'));
            %             else
            %                 g = plant.Gamma;
            %             end
            g = plant.Gamma;
            
            n_vertex = height(g.Nodes);
            n_edge = height(g.Edges);
            assert(n_edge==n_vertex || n_edge+1==n_vertex);
            n_phase = n_vertex + n_edge;
            
            phase(n_phase) = TrajectoryOptimization();
            
            for i=1:n_vertex
                % node name as the NLP name
                node_name = g.Nodes.Name{i};
                % the dynamical system associated with the node
                node_system = g.Nodes.Domain{i};
                
                % number of grid
                node_ngrid = [];
                if nargin > 2
                    if ~isempty(num_grid)
                        if isfield(num_grid, node_name)
                            node_ngrid = num_grid.(node_name);
                        end
                    end
                end
                
                
                
                % construct a standard trajectory optimization problem for
                % the continuous dynamics
                idx = 2*i-1;
                phase(idx) = TrajectoryOptimization(node_name,...
                    node_system, node_ngrid, [], varargin{:});
                
                % find the associated edge
                next = successors(g, i);
                if ~isempty(next)
                    edge = findedge(g,i,next);
                    edge_name = g.Edges.Guard{edge}.Name;
                    edge_system = g.Edges.Guard{edge};
                    phase(idx+1) = TrajectoryOptimization(edge_name,...
                        edge_system, 0, [], varargin{:});
                end
                
                
            end
                
            obj.Gamma = g;
            obj.Phase = phase;
            obj.PhaseVarIndices = zeros(n_phase,2);
            
            if nargin > 3
                if ~isempty(bounds)
                    obj = configure(obj, bounds);
                end
            end
            
        end
        
        
        
        
    end
    
    
    
    %% methods defined in external files
    methods
        obj = addJumpConstraint(obj, edge, src, tar, bounds, varargin);

        validateGraph(~, plant);
        
        obj = configure(obj, bounds, varargin);
        
        obj = updateVariableBounds(obj, bounds);
        
        [obj] = update(obj);
        
        phase_idx = getPhaseIndex(obj, varargin);
        
        [yc, cl, cu] = checkConstraints(obj, x, tol, output_file);
        
        [yc] = checkCosts(obj, x, output_file);
        
        checkVariables(obj, x, tol, output_file);
        
        [tspan, states, inputs, params] = exportSolution(obj, sol);
        
        compileConstraint(obj, phase, constr, export_path, exclude, varargin);
        
        compileObjective(obj, phase, cost, export_path, exclude, varargin);
    end
end

