function obj = configurePhase(obj, plant, options)
    % Sets the hybrid system plant of the trajectory optimization problem.
    %
    % Parameters:
    % options: optimization options of hybrid system @type struct
    %
    %
    % Optional fields of options:
    % subgraph: the node list of the subgraph to be optimized @type colvec
    % start: the first domain from which the optimization starts, 
    % the first domain in the graph if not explicitly specified @type char
    % terminal: the last domain at which the optimization terminates, 
    % empty if not explicitly specified 
    % @type char
    
    
    % check the type of the plant
    assert(isa(plant, 'HybridSystem'),...
        'HybridTrajectoryOptimization:invalidPlant',...
        'The plant must be an object of HybridSystem catagory.\n');
    
    if nargin < 3
        options = struct;
    end
    
    if isfield(options, 'subgraph')
        % if a subgraph is specified to be simulated, then extract this
        % subgraph.
        opt_graph = subgraph(plant.Gamma, options.subgraph);
        
        
    else
        % otherwise use the original whole graph for simulation
        opt_graph = plant.Gamma;
    end
    
    
    if isfield(options, 'start')
        % specify the starting node of the graph
        s_domain_idx = findnode(opt_graph, options.start);
        % check if it is a valid node
        assert(s_domain_idx~=0, ...
            'Unbale to find the specified starting domain in the system graph.');
    else
        % if not specified explicitly, assume the graph start from the
        % first node
        s_domain_idx = 1;
    end
    
    if isfield(options, 'terminal')
        % specify the terminal node of the graph
        t_domain_idx = findnode(opt_graph, options.terminal);
        % check if it is a valid node
        assert(t_domain_idx~=0, ...
            'Unbale to find the specified end domain in the system graph.');
        % check if the terminal node is indeed a terminal (IsTerminal ==
        % true)
        if ~opt_graph.Nodes.IsTerminal(t_domain_idx)
            % if not, set it to true
            warning(['The specified terminal domain %s is not a terminal node of the system. \n',...
                'Setting %s to a terminal node: '], opt_graph.Nodes.Name{t_domain_idx}, opt_graph.Nodes.Name{t_domain_idx});
            opt_graph.Nodes.IsTerminal(t_domain_idx) = true;
        end
    else
        % if not specified explicitly, find all terminal nodes
        t_domain_idx = find(opt_graph.IsTerminal);
        % check if there is only one terminal node
        if ~isscalar(t_domain_idx)
            error('Hybrid system with multiple terminal node is not supported.');
        end
    end
    
    if isdag(opt_graph) % acyclic graph
        if ~any(opt_graph.IsTerminal)
            % there is no terminal domain exists in a acyclic graph
            error('The specified subgraph is acyclic but there is no terminal node in the graph.');
        end
    end
    
    n_vertex = height(plant.Gamma.Nodes);
    
    cur_node_idx = s_domain_idx;
    for idx = 1:n_vertex
        
        successor_node_idx = successors(plant.Gamma, cur_node_idx);
        if ~isscalar(successor_node_idx)
            error('Hybrid system with indeterministic paths is not supported.');
        end
        
        
        
        phase = struct;
        phase.VertexIndex = cur_node_idx;
        phase.SuccessorVertex = successor_node_idx;
        phase.Domain = plant.Gamma.Nodes.Domain{cur_node_idx};
        
        if successor_node_idx == t_node_idx
            phase.NumNode = 1;
            phase.IsTerminal = true;
            phase.Guard = [];
        else
            edge_idx = findedge(plant.Gamma, cur_node_idx, successor_node_idx);
            phase.Guard  = plant.Gamma.Edges.Guard{edge_idx};
            
            switch obj.Options.CollocationScheme
                case 'HermiteSimpson'
                    phase.NumNode = num_grids(cur_node_idx)*2 + 1;
                case 'Trapzoidal'
                    phase.NumNode = num_grids(cur_node_idx) + 1;
                case 'PseudoSpectral'
                    phase.NumNode = num_grids(cur_node_idx) + 1;
            end
            phase.IsTerminal = false;
        end
        col_name = cellfun(@(x)['node',num2str(x)], num2cell(1:phase.NumNode),...
            'UniformOutput',false);
        phase.OptVarTable = cell2table(cell(0,phase.NumNode),...
            'VariableName',col_name);
        phase.ConstrTable = cell2table(cell(0,phase.NumNode),...
            'VariableName',col_name);
        phase.CostTable   = cell2table(cell(0,phase.NumNode),...
            'VariableName',col_name);
        
        obj.Phase{idx} = phase;
        cur_node_idx = successor_node_idx;
    end
    

    
    
    
end