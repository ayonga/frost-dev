function [obj] = addConstraint(obj, funcs)
    % This method registers the information of a NLP function as
    % a constraint
    %
    % Parameters:
    %  funcs: a list of contraint functions @type NlpFunction
    %
    %  @see NlpFunction
    
    obj.constr_array = appendTo(obj.constr_array, funcs);
    
end