function [obj] = genVarIndices(obj)
    % Generates indices for NLP variables
    
    obj.VariableArray = genIndices(obj.VariableArray);
    
end