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
        x = vertcat(cellfun(@(x)x.InitialValue, obj.DepVariables, ...
            'UniformOutput', false));
    end
    
    if nargin < 3
        derivative_level = 1;
    end

    if isempty(obj.AuxData)
        f_value = feval(obj.Funcs.Func, x);
        j_value = feval(obj.Funcs.Jac, x);
        if derivative_level == 2
            h_value = feval(obj.Funcs.Hess, x, ones(obj.Dimension,1));
        else
            h_value = [];
        end
    else
        f_value = feval(obj.Funcs.Func, x, obj.AuxData);
        j_value = feval(obj.Funcs.Jac, x, obj.AuxData);
        if derivative_level == 2
            h_value = feval(obj.Funcs.Hess, x, ones(obj.Dimension,1), obj.AuxData);
        else
            h_value = [];
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
    end
    
    val = struct(...
        'f', f_value, ...
        'J', j_value, ...
        'H', h_value);

end