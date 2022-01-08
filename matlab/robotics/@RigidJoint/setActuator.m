function obj = setActuator(obj, param)
    % set the physical limits of the rigid joints
    %
    % Parameters:
    % varargin: varaiable input arguments. In detail:
    %  Inertia: the inertia of the actuator (before gear box) @type double
    %  Ratio: the deceleration ratio of the gear box @type double 
    
    % set the actuator to empty (remove actuation) if no argument is
    % detected
    
    arguments
        obj
        param.RotorInertia double {mustBeScalarOrEmpty,mustBeReal,mustBeNonnegative,mustBeFinite}
        param.GearRatio double {mustBeScalarOrEmpty,mustBeReal,mustBePositive,mustBeFinite}
    end
    
    
    if isempty(fieldnames(param))
        obj.Actuator = [];
        return;
    end
    
    if isempty(obj.Actuator)
        obj.Actuator = struct('RotorInertia',[],'GearRatio',[]);
    end
    
    fields = fieldnames(obj.Actuator);
    for i=1:length(fields)
        if isfield(param, fields{i})
            obj.Actuator.(fields{i}) = param.(fields{i});
        end
    end
    if isfield(param,'RotorInertia')
        B_j = obj.TwistAxis;
        obj.Gm = diag(obj.Actuator.RotorInertia * B_j);
    else
        obj.Gm = zeros(6);
    end
    
    
    
end