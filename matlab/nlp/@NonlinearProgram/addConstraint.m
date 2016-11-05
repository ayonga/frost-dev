function [obj] = addConstraint(obj, name, deps, dimension, cl, cu, extra)
    % This method registers the information of a NLP function as a
    % constraint
    %
    % Parameters:
    %  name: name of the variable @type char
    %  deps: a list of dependent variables @type cell
    %  dimension: the dimension of the constraint vector
    %  cl: the lower bound
    %  cu: the upper bound
    %  extra: (optional) extra input argument for functions
    %
    %  @see NlpConstr NlpFcn
    
    
    % opt variables have to be registered before adding constraints
    assert(~isempty(obj.varIndex),...
        'NonlinearProgram:incorrectProcedure',...
        ['Constraint can be registered only after generated variables indices.\n',...
        'Please run genVarIndices first.\n']);
    
    if nargin < 7
        extra = [];
    end
    
    % construct the optimization varibale information
    new_constr  = NlpConstraint(name, dimension, cl, cu, extra, ...
        'withHessian', obj.options.withHessian);
    
    nDeps = numel(deps);
    depIndices = [];
    for i = 1:nDeps
        var    = deps{i};
        depIndices = [depIndices,...
            obj.varIndex.(var)];
    end
    
    new_constr = setDependentIndices(...
        new_constr, depIndices);
    
    
    obj.constrArray{end+1} = new_constr;
    
end