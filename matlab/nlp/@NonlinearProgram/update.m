function [obj] = update(obj)
    % Updates the NLP problems before load it to NLP solver
    

    
    
    
    % update variable indices
    index_offset = 0;
    
    num_vars = numel(obj.VariableArray);

    for i = 1:num_vars
        dim = obj.VariableArray(i).Dimension;
        
        % set the index
        setIndices(obj.VariableArray(i),index_offset + cumsum(ones(dim,1)));

        % increments (updates) offset
        index_offset = index_offset + dim;
    end
    
end