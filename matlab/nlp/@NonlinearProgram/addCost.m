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
    %  @see NlpCost NlpFunction
    
    % opt variables have to be registered before adding constraints
    assert(~isempty(obj.varIndex),...
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
            obj.varIndex.(var)];
    end
    
    new_cost = setDependentIndices(...
        new_cost, depIndices);
    
    
    % insert to the end of the cell array
    obj.costArray{end+1} = new_cost;
    
end