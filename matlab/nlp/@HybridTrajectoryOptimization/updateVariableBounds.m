function obj = updateVariableBounds(obj, bounds)
    % This function updates the boundary conditions of the optimization
    % variable by updating corresponding NLP variables
    %
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    g = obj.Gamma;
    n_vertex = height(g.Nodes);
    
    
    for i=1:n_vertex
        idx = 2*i - 1;
        node_name = g.Nodes.Name{i};
        if isfield(bounds, node_name)
            updateVariableBounds(obj.Phase(idx),bounds.(node_name));
        end
        
        % find the associated edge
        next = successors(g, i);
        if ~isempty(next)
            edge = findedge(g,i,next);
            edge_name = g.Edges.Guard{edge}.Name;
            if isfield(bounds, edge_name)
                updateVariableBounds(obj.Phase(idx+1),bounds.(edge_name));
            end
        end
        
        
    end
    
   
    
    
    
end
