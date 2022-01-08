function obj = setDependentVariable(obj, depvars)
    % This function sets the dependent variables of the function
    %
    % Parameters:
    %  depvars: an array of dependent variables @type
    %  NlpVariables

    arguments
        obj
        depvars (:,1) NlpVariable
    end
    

    if ~isempty(obj.SymFun)
        
        assert(length(depvars) == numel(obj.SymFun.Vars),...
            'The number of the constant parameters does not match.');
        
        nvar1 = cellfun(@(x)length(x), obj.SymFun.Vars);        
        nvar2 = arrayfun(@(x)x.Dimension, depvars); 
        
        for i=1:numel(depvars)
            
            assert(nvar1(i) == nvar2(i),...
                'The dimension of the %d-th dependent variable does not match.',i);
        end
        
        
    end
    
    obj.DepVariables = depvars;

    
    

    % evaluate the function using typical values of dependent
    % variables
    %     x0 = vertcat(obj.DepVariables(:).InitialValue);

    % if isempty(obj.AuxData)
    %     f_value = feval(obj.Name, x0);
    % else
    %     f_value = feval(obj.Name, x0, obj.AuxData{:});
    % end
    % % get the dimension of the function
    % obj.Dimension = length(f_value);

    % % store the dependent indices for quick access
    % obj.DepIndices = vertcat(obj.DepVariables.Indices);

    % default sparsity pattern of the (full) Jacobian matrix
    %     dimDeps = sum([obj.DepVariables.Dimension]);
    %     obj = setJacobianPattern(obj, ones(obj.Dimension, dimDeps), 'MatrixForm');

end