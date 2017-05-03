function [xdot, extra] = calcDynamics(obj, t, x, controller, params)
    % calculate the dynamical equation dx 
    %
    % Parameters:
    % t: the time instant @type double
    % x: the states @type colvec
    % controller: the controller @type Controller
    % params: the parameter structure @type struct
    
    if strcmp(obj.Type,'FirstOrder')
        if nargout > 1
            [xdot, extra] = firstOrderDynamics(obj, t, x, controller, params);
        else
            [xdot] = firstOrderDynamics(obj, t, x, controller, params);
        end
    else
        if nargout > 1
            [xdot, extra] = secondOrderDynamics(obj, t, x, controller, params);
        else
            [xdot] = secondOrderDynamics(obj, t, x, controller, params);
        end
    end
end