function logger = simulate_stand(obj, t0, x0, tf, options, varargin,alpha,min,max)
% Simulate the hybrid dynamical system
%
% Parameters:
% t0: the starting time @type double
% x0: the initial condition states @type colvec
% tf: the terminating time @type double
% options: the ODE options @type struct
% varargin: extra simulation options
%
% Return values:
% logger: an array of simulation logger data @type SimLogger
global  switchCont_e
% global m x1 x2

sim_opts = struct(varargin{:});
if isfield(sim_opts,'NumCycle')
    numcycle = sim_opts.NumCycle;
else
    numcycle = 1;
end

sim_graph = obj.Gamma;
idx_no_in = find(indegree(sim_graph)==0,1);
if ~isempty(idx_no_in)
    s_domain_idx = idx_no_in;
else
    s_domain_idx = 1;
end

idx_no_out = find(outdegree(sim_graph)==0,1);
if ~isempty(idx_no_in)
    t_domain_idx = idx_no_out;
else
    t_domain_idx = [];
end




% initialization
cur_node_idx = s_domain_idx;
log_idx = 0;
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
    eventnames = cell(1,n_edges);
    for i=1:n_edges
        eventnames{i} = assoc_edges.Guard{i}.EventName;
    end
    
    log_idx = log_idx + 1;
    logger(log_idx) = feval(obj.Options.Logger, cur_domain); %#ok<AGROW>
    virt_constr=struct2array(cur_domain.VirtualConstraints);
%     if  ~strcmp(cur_domain.Name,'sit2')
%         switchCont_e=0;
%     end
    if ~strcmp(cur_domain.Name,'slowDown') && any(strcmp(fieldnames(virt_constr),'PhaseParamName')) && strcmp(virt_constr.PhaseParamName,'ptrajectoryStand')&& strcmp(cur_domain.Name,'standKnee') && isfield(cur_param,'ptrajectoryStand')
        cur_param.ptrajectoryStand=ExoCalculations.TauReset(cur_param.ptrajectoryStand(1),cur_param.ptrajectoryStand(2),logger(3).flow.t(1));
        %switchCont_e=1;
    elseif  ~strcmp(cur_domain.Name,'sit2')
         switchCont_e=0;
    end
    % run the simulation
    sol = cur_domain.simulate_stand(t0,x0,tf,cur_control,cur_param,...
        logger(log_idx),eventnames,options,obj.Options.OdeSolver,alpha,min,max);
    
    
    
    
    % check the index of the triggered edge
    cur_edge  = assoc_edges(unique(sol.ie), :);
    assert(height(cur_edge)<=1,...
        'There are more than one event triggered.');
    if isempty(cur_edge)
        break;
    end
    cur_guard = cur_edge.Guard{1};
    cur_gurad_param = cur_edge.Param{1};
    % update states and time
    [t0, x0] = cur_guard.calcDiscreteMap(sol.xe, sol.ye, cur_node, cur_gurad_param);
    
% %     if strcmp(cur_node.Name{1},'standBlend')
% %         m=logger(2).flow.mu(3,end);
% %         x1=logger(2).flow.mu(1,end);
% %         x2=logger(2).flow.mu(2,end);
% %     end
% %     
    
    % determine the target node of the current edge, and set it to be
    % the current node
    try
        cur_node_name = cur_edge.EndNodes{1,2};
        cur_node_idx = findnode(sim_graph, cur_node_name);
    catch
        cur_node_idx = cur_edge.EndNodes(2);
    end
    
    
% %uncomment if you want to stop the simulation at the domain number that's equated to cur_node_idx     
%         if cur_node_idx==3
%             cur_node_idx=1;
%         end
    % %
    % if the next node is the starting node of the graph, it indicates
    % that one full cycle is completed.
    %         cur_node_idx=1;
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