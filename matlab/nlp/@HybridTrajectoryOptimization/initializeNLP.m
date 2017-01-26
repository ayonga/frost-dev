function obj = initializeNLP(obj, options)
    % Initializes the trajectory optimization problem.
    %
    % Parameters:
    % options: optimization options of hybrid system @type struct
    %
    %
    % Optional fields of options:
    % SubGraph: the node list of the SubGraph to be optimized @type colvec
    % StartingVertex: the first domain from which the optimization StartingVertexs, 
    % the first domain in the graph if not explicitly specified @type char
    % TerminalVertex: the last domain at which the optimization terminates, 
    % empty if not explicitly specified 
    % @type char
    
    
    
    
    
    if nargin < 2
        options = struct;
    end
    
    if isfield(options, 'SubGraph')
        % if a SubGraph is specified to be simulated, then extract this
        % SubGraph.
        obj.Gamma = subgraph(obj.Gamma, options.SubGraph);
    end
    
    opt_graph = obj.Gamma;
    
    
    if isfield(options, 'StartingVertex')
        % specify the StartingVertexing node of the graph
        s_domain_idx = findnode(opt_graph, options.StartingVertex);
        % check if it is a valid node
        assert(s_domain_idx~=0, ...
            'Unbale to find the specified StartingVertexing domain in the system graph.');
    else
        % if not specified explicitly, assume the graph StartingVertex from the
        % first node
        s_domain_idx = 1;
    end
    
    if isfield(options, 'TerminalVertex')
        % specify the TerminalVertex node of the graph
        t_domain_idx = findnode(opt_graph, options.TerminalVertex);
        % check if it is a valid node
        assert(t_domain_idx~=0, ...
            'Unbale to find the specified end domain in the system graph.');
        % check if the TerminalVertex node is indeed a TerminalVertex (IsTerminal ==
        % true)
        if ~opt_graph.Nodes.IsTerminal(t_domain_idx)
            % if not, set it to true
            warning(['The specified TerminalVertex domain %s is not a TerminalVertex node of the system. \n',...
                'Setting %s to a TerminalVertex node: '], opt_graph.Nodes.Name{t_domain_idx}, opt_graph.Nodes.Name{t_domain_idx});
            opt_graph.Nodes.IsTerminal(t_domain_idx) = true;
        end
    else
        % if not specified explicitly, find all TerminalVertex nodes
        t_domain_idx = find(opt_graph.Nodes.IsTerminal);
        % check if there is only one TerminalVertex node
        if numel(t_domain_idx) > 1
            error('Hybrid system with multiple TerminalVertex node is not supported.');
        end
    end
    
    if isdag(opt_graph) % acyclic graph
        if ~any(opt_graph.Nodes.IsTerminal)
            % there is no TerminalVertex domain exists in a acyclic graph
            error('The specified SubGraph is acyclic but there is no TerminalVertex node in the graph.');
        end
    end
    
    n_vertex = height(opt_graph.Nodes);
    
    cur_node_idx = s_domain_idx;
    for idx = 1:n_vertex
        
        successor_node_idx = successors(opt_graph, cur_node_idx);
        if ~isscalar(successor_node_idx) && cur_node_idx~=t_domain_idx
            error('Hybrid system with indeterministic paths is not supported.');
        end
        
        
        
        phase = struct;
        phase.VertexIndex = cur_node_idx;
        phase.NextVertex = successor_node_idx;
        phase.Domain = opt_graph.Nodes.Domain{cur_node_idx};
        
        if successor_node_idx == t_domain_idx
            phase.NumNode = 1;
            phase.IsTerminal = true;
            phase.Guard = [];
        else
            edge_idx = findedge(opt_graph, cur_node_idx, successor_node_idx);
            if ~isempty(edge_idx)
                phase.Guard  = opt_graph.Edges.Guard{edge_idx};
            else
                phase.Guard = [];
            end
            num_grids = obj.Options.DefaultNumberOfGrids;
            switch obj.Options.CollocationScheme
                case 'HermiteSimpson'
                    phase.NumNode = num_grids*2 + 1;
                case 'Trapzoidal'
                    phase.NumNode = num_grids + 1;
                case 'PseudoSpectral'
                    phase.NumNode = num_grids + 1;
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
        cur_node_idx = cur_node_idx + 1;
    end
    
    
    obj = genericSymFunctions(obj);
    
end