function obj = changeDesiredOutputType(obj, varargin)
    % Sets the function type of desired outputs
    %
    % Parameters:
    % varargin: name-parameter pairs of input argument.

    des = struct(varargin{:});

    if isfield(des, 'VelocityOutput')
        obj.DesVelocityOutput.Type = des.VelocityOutput;

        n_param = obj.getDesOutputExpr(des.VelocityOutput);
        obj.Parameters.v = nan(1,n_param);
        warning(['The desired velocity output type has been changed, ',...
            'and the corresponding parameters are set to NaN.']);
    end

    if isfield(des, 'PositionOutput')
        obj.DesPositionOutput.Type = des.PositionOutput;

        n_param = obj.getDesOutputExpr(des.PositionOutput);
        n_output = getDimension(obj.ActPositionOutput);
        obj.Parameters.a = nan(n_output,n_param);
        warning(['The desired position output type has been changed, ',...
            'and the corresponding parameters are set to NaN.']);
    end

end