function [obj] = addVariable(obj, vars)
    % This method registers the information of an optimization
    % variable
    %
    % Parameters:
    %  vars: new NLP variables @type NlpVariable 
    %
    
    
    obj.var_array = appendTo(obj.var_array, vars);
    
    
end