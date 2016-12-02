function [obj] = genVarIndices(obj)
    % Generates indices for NLP variables
    
    obj.var_array = genIndices(obj.var_array);
    
end