function [value, isterminal, direction] = checkGuard(obj, t, x, controller, params, eventfuncs)
    % Detect the guard condition (event trigger)
    %
    % Parameters:
    %  t: the absolute time @type double
    %  x: the system states @type colvec
    %  controller: the controller @type Controller
    %  params: the parameter structure @type struct
    %  eventfuncs: a list of event function @type UnilateralConstraint
    
    nevent = numel(eventfuncs);
    % we always assumes that the guard function is from positive to
    % negative
    direction  = -ones(1, nevent); % -1: pos->neg
    isterminal = ones(1, nevent);  % all are terminal
    
    % if any of the event function is input-dependent, then call
    % calcDynamics method.
    if any([eventfuncs.InputDependent])
        calcDynamics(obj, t, x, controller, params, []);
    else
        if strcmp(obj.Type,'FirstOrder')
            obj.t_ = t;
            obj.states_.x = x;
        else
            obj.t_ = t;
            nx = obj.numState;
            obj.states_.x = x(1:nx);
            obj.states_.dx = x(nx+1:end);
        end
    end
    
    % call the event function of each guard to compute the value of events
    value = ones(1,nevent);
    for i=1:nevent
        % get the value of the dependent variables
        dep_val = getValue(obj,eventfuncs(i).DepLists);
        
        % compute the value of the event function
        value(i) = eventfuncs(i).calcConstraint(dep_val{:});
    end
   
    
end
