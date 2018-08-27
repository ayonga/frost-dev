function obj = updateConstraintBounds(obj, bounds, varargin)
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
            updateConstraintBounds(obj.Phase(idx),bounds.(node_name),varargin{:});
        end
        
        
        
        
    end
    
    for i=1:n_vertex
        
        next = successors(g,i);
                
        if ~isempty(next)
            edge = findedge(g,i,next);
            edge_name = g.Edges.Guard{edge}.Name;
            if isfield(bounds, edge_name)
                src_idx = 2*i-1;
                src = obj.Phase(src_idx);
                
                edge_idx = src_idx + 1;
                edge = obj.Phase(edge_idx);
                
                tar_idx = 2*next - 1;
                tar = obj.Phase(tar_idx);
                
                updateConstraintBounds(edge, src, tar, bounds.(edge_name),varargin{:});
            end
        end
    end
    
end
