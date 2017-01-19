function [obj] = addConstraint(obj, funcs)
    % This method registers the information of a NLP function as
    % a constraint
    %
    % Parameters:
    %  funcs: a list of contraint functions @type NlpFunction
    %
    %  @see NlpFunction
    
    obj.ConstrArray = appendTo(obj.ConstrArray, funcs);
    
end