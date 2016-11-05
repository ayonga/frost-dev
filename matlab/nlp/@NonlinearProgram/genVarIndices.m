function obj = genVarIndices(obj)
    % Generate indices for all optimization variables. It must be
    % run after registered all optimization variables
    
    index0 = 0;
    
    for i=1:length(obj.varArray)
        var = obj.varArray(i);
        
        obj.varIndex.(var.name) = ...
            index0 + cumsum(ones(1,var.dimension));
        
        % updates offset
        index0 = index0 + var.dimension;
    end
    
    
end