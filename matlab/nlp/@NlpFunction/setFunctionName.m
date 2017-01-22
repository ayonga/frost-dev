function obj = setFunctionName(obj, func_name)
    % This function specify the function (name) that calculates the
    % Jacobian matrix of the function

    obj.Func = func_name;

    % test function
    x0 = vertcat(obj.DepVariables(:).InitialValue);

    if isempty(obj.AuxData)
        f_value = feval(obj.Func, x0);
    else
        f_value = feval(obj.Func, x0, obj.AuxData{:});
    end

    %| @todo check if it is valid?
end