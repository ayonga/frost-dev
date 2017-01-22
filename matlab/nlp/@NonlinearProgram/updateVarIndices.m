function [obj] = updateVarIndices(obj)
    % Generates indices for NLP variables
    
    obj.VariableArray = genIndices(obj.VariableArray);
    
end