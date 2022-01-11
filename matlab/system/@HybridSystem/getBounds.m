function bounds= getBounds(obj)
    % bounds = getBounds(obj) returns a struct that contains the boundary
    % data of state/input/param variables defined for the system.
    
    bounds = struct;
    if ~isempty(obj.Gamma.Nodes)
        for i=1:height(obj.Gamma.Nodes)
            domain = obj.Gamma.Nodes.Domain{i};
            bounds.(domain.Name) = getBounds(domain);
        end
    end
    
    if ~isempty(obj.Gamma.Edges)
        for i=1:height(obj.Gamma.Edges)
            guard = obj.Gamma.Edges.Guard{i};
            bounds.(guard.Name) = getBounds(guard);
        end
    end


end