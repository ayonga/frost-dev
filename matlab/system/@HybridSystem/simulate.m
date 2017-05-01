function sol = simulate(obj, options, varargin)
    % Simulate the hybrid dynamical system
    %
    % Parameters: 
    % options: simulation options of hybrid system @type struct
    %
    %
    % Optional fields of options:
    % subgraph: the node list of the subgraph to be simulated @type colvec
    % start: the first domain from which the simulation starts, 
    % the first domain in the graph if not explicitly specified @type char
    % terminal: the last domain at which the simulation terminates, 
    % empty if not explicitly specified 
    % @type char
    % numcycle: the number of cycle if the simulated system is periodic,  
    % 1 if not specified @type double
    % x0: the initial states of the system, zero if not specified
    % @type colvec
    
    % parse simulation options
    if nargin < 2
        options = struct;
    end
    
    if isfield(options, 'subgraph')
        % if a subgraph is specified to be simulated, then extract this
        % subgraph.
        sim_graph = subgraph(obj.Gamma, options.subgraph);
        
        
    else
        % otherwise use the original whole graph for simulation
        sim_graph = obj.Gamma;
    end
    
    
    if isfield(options, 'start')
        s_domain_idx = findnode(sim_graph, options.start);
        assert(s_domain_idx~=0, ...
            'Unbale to find the specified starting domain in the system graph.');
    else
        s_domain_idx = 1;
    end
    
    if isfield(options, 'terminal')
        if isfield(options, 'numcycle')
            warning('It is not allowed to specify the terminal domain and the number of cycle at the same time.');
        end
        t_domain_idx = findnode(sim_graph, options.terminal);
        assert(t_domain_idx~=0, ...
            'Unbale to find the specified end domain in the system graph.');
        if ~sim_graph.Nodes.IsTerminal(t_domain_idx)
            warning(['The specified terminal domain %s is not a terminal node of the system. \n',...
                'Setting %s to a terminal node: '], sim_graph.Nodes.Name{t_domain_idx}, ...
                sim_graph.Nodes.Name{t_domain_idx});
            sim_graph.Nodes.IsTerminal(t_domain_idx) = true;
        end
    else
        if isfield(options, 'numcycle')
            if isdag(sim_graph)
                error('The simulated graph is acyclic. It is not allowed to specify the number of cycles.');                
            end
            numcycle = options.numcycle;
        else
            numcycle = 1;
        end
        t_domain_idx = find(sim_graph.Nodes.IsTerminal);
    end
    
    
    if isdag(sim_graph) % acyclic graph
        if ~any(sim_graph.Nodes.IsTerminal)
            % there is no terminal domain exists in a acyclic graph
            error('The specified subgraph is acyclic but there is no terminal node in the graph.');
        end
    end
    
    
            
    
    
    % initialization
    cur_node_idx = s_domain_idx;
    t0 = 0;
    while (true)
        
        
        if isempty(cur_node_idx)
            % if 'cur_node_idx' is empty, then there is no successor node
            % in the graph, terminate the simulation loop
            break;
        end
        
        if ~isempty(t_domain_idx) 
            if cur_node_idx == t_domain_idx
                % if 'cur_node_idx' reaches the terminal node, terminate the simulation
                break;
            end
        end
        
        % the current node in the graph
        cur_node = sim_graph.Nodes(cur_node_idx,:);
        % the current domain defined on the node
        cur_domain  = cur_node.Domain{1};
        cur_control = cur_node.Control{1};
        cur_param   = cur_node.Param{1}; 
        % find successors nodes
        successor_nodes = successors(sim_graph, cur_node_idx);
        % find edges that may be triggered at the current node
        assoc_edges = sim_graph.Edges(findedge(sim_graph, cur_node_idx, successor_nodes),:);
        
        % pre-process all associated guards to set up proper event function
        n_edges = height(assoc_edges);
        guards = assoc_edges.Guard;
        params = assoc_edges.Param;
        for i=1:n_edges
            guards{i}.preProcess(cur_node, params{i});
        end
        
       
        
        % run the simulation
        sol = cur_domain.simulate(t0,x0,tf,cur_control,cur_param,odeopts);
        
        
        
        
        % check the index of the triggered edge
        cur_edge  = assoc_edges(sol.ie, :);
        if isempty(cur_edge)
            break;
        end
        cur_guard = cur_edge.Guard{1};
        % update states and time
        x0 = cur_guard.calcDiscreteMap(obj, t_f, x_f, cur_node);
        t0 = t_f;
        
        % determine the target node of the current edge, and set it to be
        % the current node
        try
            cur_node_name = cur_edge.EndNodes{2};
            cur_node_idx = findnode(sim_graph, cur_node_name);
        catch
            cur_node_idx = cur_edge.EndNodes(2);
        end
        
        
        
        
        % if the next node is the starting node of the graph, it indicates
        % that one full cycle is completed.
        if cur_node_idx == s_domain_idx
            numcycle = numcycle - 1;
            % if the number of cycles achieved, then terminate the simulation
            % loop
            if numcycle <= 0
                break;
            end
        end
        
        
        
    end
    
    
    
    
    
end