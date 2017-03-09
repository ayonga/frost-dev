function obj = simulate(obj, options)
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
    
    if isfield(options, 'x0')
        x0 = options.x0;
    else
        x0 = zeros(2*obj.Model.nDof,1);
    end
            
    
    % clear previous results
    obj.Flow = [];
    
    cur_node_idx = s_domain_idx;
    t0 = 0;
    idx = 0;
    while (true)
        idx = idx + 1;
        
        
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
        
        % find successors and associated edges
        successor_nodes = successors(sim_graph, cur_node_idx);
        
        assoc_edges = sim_graph.Edges(findedge(sim_graph, cur_node_idx, successor_nodes),:);
        
        cur_node = sim_graph.Nodes(cur_node_idx,:);
        
        
        cur_node.Domain{1} = setParam(cur_node.Domain{1}, cur_node.Param{1});
        
        % configure the ODE
        odeopts = odeset('MaxStep', 1e-2,'RelTol',1e-6,'AbsTol',1e-6,...
            'Events', @(t, x) checkGuard(obj, t, x, cur_node, assoc_edges));
        
        
        
        sol = ode45(@(t, x) calcDynamics(obj, t, x, cur_node), ...
            [t0, t0+3], x0, odeopts);
        
        
        % log simulation data
        %         obj.Flow{idx} = struct;
        
        
        if ~isfield(options, 'n_sample')
            n_sample = length(sol.x);
            calcs = cell(1,n_sample);
            for i=1:n_sample
                [~,extra] = calcDynamics(obj,  sol.x(i), sol.y(:,i), cur_node);
                value = checkGuard(obj, sol.x(i), sol.y(:,i), cur_node, assoc_edges);
                extra.guard_value = value;
                calcs{i} = extra;
            end
        else
            n_sample = options.n_sample;
            t_domain = sol.x(end)-sol.x(1);
            [tspan,xsample] = even_sample(sol.x,sol.y,n_sample/t_domain);
            for i=1:n_sample+1
                [~,extra] = calcDynamics(obj,  tspan(i), xsample(:,i), cur_node);
                value = checkGuard(obj, tspan(i), xsample(:,i), cur_node, assoc_edges);
                extra.guard_value = value;
                calcs{i} = extra;
            end
        end
        
        obj.Flow{idx} = horzcat_fields([calcs{:}]);
        obj.Flow{idx}.node_idx = cur_node_idx;
        % Compute reset map at the guard
        t_f = sol.x(end);
        x_f = sol.y(:,end);
        
        triggered_edge  = assoc_edges(sol.ie, :);
        
        try
            cur_node_name = triggered_edge.EndNodes{2};
            cur_node_idx = findnode(sim_graph, cur_node_name);
        catch
            cur_node_idx = triggered_edge.EndNodes(2);
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
        
        % update states and time
        x0 = calcResetMap(obj,  x_f, triggered_edge);
        t0 = t_f;
        
    end
    
    
    
    
    
end