function obj = setJacobianFunction(obj, func_name)
    % This function specify the function (name) that calculates the
    % Jacobian matrix of the function

    obj.JacFunc = func_name;

    % test function
    x0 = vertcat(obj.DepVariables(:).InitialValue);

    if isempty(obj.AuxData)
        j_value = feval(obj.JacFunc, x0);
    else
        j_value = feval(obj.JacFunc, x0, obj.AuxData{:});
    end

    %| @todo check if it is valid?
end