function obj = genVarIndices(obj)
    % Generate indices for all optimization variables. It must be
    % run after registered all optimization variables
    
    index0 = 0;
    
    for i=1:length(obj.optVars)
        var = obj.optVars(i);
        
        obj.optVarIndices.(var.name) = ...
            index0 + cumsum(ones(1,var.dimension));
        
        % updates offset
        index0 = obj.optVarIndices.(var.name)(end);
    end
    
    
end