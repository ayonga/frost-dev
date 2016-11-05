function [obj] = addCost(obj, name, deps, extra)
    % This method registers the information of a NLP function as a
    % cost function
    %
    % Parameters:
    %  name: name of the variable @type char
    %  deps: a list of dependent variables @type cell
    %  extra: (optional) extra constant input argument for
    %  functions
    %
    %  @see NlpFcn
    
    % opt variables have to be registered before adding constraints
    assert(~isempty(obj.optVarIndices),...
        'NonlinearProgram:incorrectProcedure',...
        ['Cost function can be registered only after generated variables indices.\n',...
        'Please run genVarIndices first.\n']);
    
    if nargin < 4 % no extra argument is provided
        extra = [];
    end
    
    % construct the optimization varibale information
    new_cost  = NlpCost(name, extra, ...
        'withHessian', obj.options.withHessian);
    
    nDeps = numel(deps);
    depIndices = [];
    for i = 1:nDeps
        var    = deps{i};
        depIndices = [depIndices,...
            obj.optVarIndices.(var)];
    end
    
    new_cost = setDependentIndices(...
        new_cost, depIndices);
    
    
    if isempty(obj.costArray)
        obj.costArray = new_cost;
    else
        % specifies the next entry point
        next_entry = numel(obj.costArray) + 1;
        
        obj.costArray(next_entry) = new_cost;
    end
end