function obj = setDependentVariable(obj, depvars)
    % This function sets the dependent variables of the function
    %
    % Each cell may contains an array of NlpVariable objects. After
    % configuration, the funcion will be evaluated using typical
    % values of dependent variables. This process first checks if
    % the given function has been defined, and also determines the
    % dimension of the function
    %
    % Parameters:
    %  depvars: a cell array of dependent variables @type
    %  NlpVariables

    assert(iscell(depvars),...
        'NlpFunction:setDependentError',...
        'The list of dependent variables must be a cell array.\n');

    assert(all(cellfun(@(x)isa(x,'NlpVariable'),depvars)),...
        'NlpFunction:incorrectDataType',...
        'Each cell must consists of a single or an array of NlpVariable objects.\n');


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