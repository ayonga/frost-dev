function [obj] = addVariable(obj, vars)
    % This method registers the information of an optimization
    % variable
    %
    % Parameters:
    %  vars: new NLP variables @type NlpVariable 
    %
    
    
    obj.VariableArray = appendTo(obj.VariableArray, vars);
    
    
end