function [obj] = addObjective(obj, funcs)
    % This method registers the information of a NLP function as a
    % cost function
    %
    % Parameters:
    %  funcs: a list of objective functions @type NlpFunction
    %
    %  @see NlpFunction
    
    obj.objective_array = appendTo(obj.objective_array, funcs);
    
end