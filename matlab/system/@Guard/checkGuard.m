function [value, isterminal, direction] = checkGuard(obj, t, x, domain, model)
    % Detect the guard condition (event trigger)

    % substract 'q' from 'x' 
    qe = x(model.qe_indices);
    dqe = x(model.dqe_indices);

    direction  = obj.direction;
    isterminal = 1;
    
    
    switch obj.type
        case 'kinematic'
            % the function for kinematics guard function will be provided
            % by mathematica-generated MEX file.
            value = feval(obj.funcs.pos, qe) - obj.threshold;
        case 'forces'
            % compute constraints forces 
            %| @todo
            [~, ~, Fe] = calcDynamics(domain, t, x, model);
            
            % compute the guard function
            value = obj.guard_func(Fe) - obj.threshold;
        case 'time'
            % compute guard condition from the time signal
            value = t - obj.threshold;
            assert(direction == 1,...
                'Time can ONLY be monotonically increasing.\n');
    end
    
    
end
