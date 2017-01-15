function obj = removePositionOutput(obj, act)
    % Removes position-modulating outputs from the domain
    %
    % Parameters:
    % act: the kinematic function for the actual position-modulating
    % output @type Kinemtics

    obj.ActPositionOutput = removeKinematic(obj.ActPositionOutput, act);

    if getDimension(obj.ActPositionOutput) == 0
        obj.ActPositionOutput = [];
        obj.DesPositionOutput = [];
    else                
        [~,n_param] = obj.getDesOutputExpr(obj.DesPositionOutput.Type);
        n_output = getDimension(obj.ActPositionOutput);
        obj.Parameters.a = nan(n_output, n_param);
    end
end