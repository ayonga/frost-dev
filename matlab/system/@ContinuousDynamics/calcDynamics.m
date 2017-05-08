function [xdot] = calcDynamics(obj, t, x, controller, params, logger)
    % calculate the dynamical equation dx 
    %
    % Parameters:
    % t: the time instant @type double
    % x: the states @type colvec
    % controller: the controller @type Controller
    % params: the parameter structure @type struct
    % logger: the data logger object @type SimLogger
    %
    % Return values:
    % xdot: the derivative of the system states @type colvec
    
    if strcmp(obj.Type,'FirstOrder')
        [xdot] = firstOrderDynamics(obj, t, x, controller, params, logger);
    else
        [xdot] = secondOrderDynamics(obj, t, x, controller, params, logger);
    end
end