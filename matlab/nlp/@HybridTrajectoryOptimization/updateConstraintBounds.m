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
            plant = obj.Phase(idx).Plant;
            plant.UserNlpConstraint(obj.Phase(idx), bounds.(node_name), varargin{:});
        end
    end
    
   
    
    
    
end
