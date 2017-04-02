function val = checkFuncs(obj, x, derivative_level)
    % Evaluates the external functions (or function handles) with a given
    % input argument.
    %
    % Parameters:
    % x: the value of dependent variables @type colvec
    % derivative_level: determines the level of derivatives to be exported
    %  (1, 2) @type double
    %
    % Return values:
    % val: a structure of computed values @type struct
    
    
    % test function
    if nargin < 2
        x = vertcat([obj.DepVariables.InitialValue]);
    end
    
    if nargin < 3
        derivative_level = 1;
    end

    if isempty(obj.AuxData)
        f_value = feval(obj.Funcs.Func, x);
        j_value = feval(obj.Funcs.Jac, x);
        j_struct = feval(obj.Funcs.JacStruct, 0);
        if derivative_level == 2
            h_value = feval(obj.Funcs.Hess, x, ones(obj.Dimension,1));
            h_struct = feval(obj.Funcs.Hess, 0, ones(obj.Dimension,1));            
        else
            h_value = [];
            h_struct = [];
        end
    else
        f_value = feval(obj.Funcs.Func, x, obj.AuxData);
        j_value = feval(obj.Funcs.Jac, x, obj.AuxData);
        j_struct = feval(obj.Funcs.JacStruct, 0);
        if derivative_level == 2
            h_value = feval(obj.Funcs.Hess, x, ones(obj.Dimension,1), obj.AuxData);
            h_struct = feval(obj.Funcs.Hess, 0, ones(obj.Dimension,1));
        else
            h_value = [];
            h_struct = [];
            h_mat = [];
        end
    end
    
    % validate computed values
    assert(length(f_value) == obj.Dimension,...
        'The dimension of the output value does not match the dimension specified.');
    
    assert(~isempty(j_value),...
        'All-zero Jacobian entries found.');
    if derivative_level == 2
        if obj.Type == NlpFunction.LINEAR
            assert(isempty(h_value),...
                'Non-zero Hessian entries found for the Linear constraints.');
        elseif obj.Type == NlpFunction.NONLINEAR
            assert(~isempty(h_value),...
                'All-zero Hessian entries found for the Non-Linear constraints.');
        end
        h_mat = sparse(h_struct(:,1), h_struct(:,2), h_value, length(x), length(x));
    end
    
    j_mat = sparse(j_struct(:,1), j_struct(:,2), j_value, length(f_value), length(x));
    
    val = struct(...
        'f', f_value, ...
        'J', j_mat, ...
        'H', h_mat);

end