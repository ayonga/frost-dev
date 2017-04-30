function obj = configure(obj, bounds)
    % configure the trajectory optimizatino NLP problem
    %
    % This process will add NLP variables based on the information of the
    % dynamical system object, impose dynamical and collocation
    % constraints, then call the system constraints callback function to
    % add any system-specific constraints.
    %
    % Parameters:
    % bounds: a struct data contains the boundary values @type struct
    g = obj.Gamma;
    n_vertex = height(g.Nodes);
    n_edge = height(g.Edges);
    n_phase = n_vertex + n_edge;
    
    
    for i=1:n_phase
        node_name = g.Nodes.Name{i};
        % boundary values
        node_bounds = [];
        if nargin > 1
            if ~isempty(bounds)
                if isfield(bounds, node_name)
                    node_bounds = bounds.(node_name);
                end
            end
        end
        idx = 2*i - 1;
        obj.Phase(idx) = configure(obj.Phase(idx),node_bounds);
        
        
        
        % find the associated edge
        next = successors(g, i);
        if ~isempty(next)
            edge = findedge(g,i,next);
            edge_name = g.Edges.Guard(edge).Name;
            
            if nargin > 1
                if ~isempty(bounds)
                    if isfield(bounds, edge_name)
                        edge_bounds = bounds.(edge_name);
                    end
                end
            end
            obj.Phase(idx+1) = configureVariables(obj.Phase(idx+1),edge_bounds);
        end
        
        
    end
    
    for i=1:n_phase
        
        next = successors(g,i);
        
        if ~isempty(next)
            src_idx = 2*i-1;
            src = obj.Phase(src_idx);
            
            edge_idx = src_idx + 1;
            edge = obj.Phase(edge_idx);
            
            tar_idx = 2*next - 1;
            tar = obj.Phase(tar_idx);
            
            addJumpConstraint(obj, edge, src, tar, bounds);
        end
    end
    
    
    
end
