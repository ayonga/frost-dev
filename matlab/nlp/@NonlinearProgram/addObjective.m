function [obj] = addObjective(obj, funcs)
    % This method registers the information of a NLP function as a
    % cost function
    %
    % Parameters:
    %  funcs: a list of objective functions @type NlpFunction
    %
    %  @see NlpFunction
    
    
    
    obj.CostArray = appendTo(obj.CostArray, funcs);
    
end