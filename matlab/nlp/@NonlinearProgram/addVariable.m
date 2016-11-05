function [obj] = addVariable(obj, name, dimension, varargin)
    % This method registers the information of an optimization
    % variable
    %
    % Parameters:
    %  name: name of the variable @type char
    %  dimension: dimension of the variable @type integer
    %  lb: lower limit @type colvec
    %  ub: upper limit @type colvec
    %
    % Syntex:
    %   nlp = addVariable(nlp, 'name', 10, 0, 1)
    %
    
    if isempty(obj.optVars)
        obj.optVars = NlpVar(name, dimension, varargin{:});
    else
        % specifies the next entry point
        next_entry = numel(obj.optVars) + 1;
        
        % construct the optimization varibale information
        obj.optVars(next_entry) = NlpVar(name, dimension, varargin{:});
    end
    
end