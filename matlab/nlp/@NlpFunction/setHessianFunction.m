function obj = setHessianFunction(obj, func_name)
    % This function specify the function (name) that calculates the
    % Jacobian matrix of the function

    obj.HessFunc = func_name;

    % test function
    x0 = vertcat(obj.DepVariables(:).InitialValue);

    if isempty(obj.AuxData)
        h_value = feval(obj.HessFunc, x0, ones(obj.Dimension,1));
    else
        h_value = feval(obj.HessFunc, x0, ones(obj.Dimension,1), obj.AuxData{:});
    end

    %| @todo check if it is valid?
end