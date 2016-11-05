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
    
    if isempty(obj.varArray)
        obj.varArray = NlpVariable(name, dimension, varargin{:});
    else
        % specifies the next entry point
        next_entry = numel(obj.varArray) + 1;
        
        % construct the optimization varibale information
        obj.varArray(next_entry) = NlpVariable(name, dimension, varargin{:});
    end
    
end