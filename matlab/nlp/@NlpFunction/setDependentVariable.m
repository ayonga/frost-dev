function obj = setDependentVariable(obj, depvars)
    % This function sets the dependent variables of the function
    %
    % Parameters:
    %  depvars: an array of dependent variables @type
    %  NlpVariables


    assert(isa(depvars,'NlpVariable'),...
        'NlpFunction:incorrectDataType',...
        'The second argument must be a scalar or an array of NlpVariable objects.\n');


    if isa(obj.SymFun,'SymFunction')
        vars = cellfun(@(x)flatten(x), obj.SymFun.Vars,'UniformOutput',false);        
        nvar1 = length([vars{:}]);
        nvar2 = sum([depvars.Dimension]);
        
        assert(nvar1 == nvar2,...
            'The dimensions of the dependent variables do not match.');
    end
    
    obj.DepVariables = depvars(:);

    
    

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