function [value, isterminal, direction] = checkGuard(obj, t, x, domain, model)
    % Detect the guard condition (event trigger)

    % substract 'q' from 'x' 
    %     qe = x(model.qe_indices);
    %     dqe = x(model.dqe_indices);

    direction  = obj.guard_direction;
    isterminal = 1;
    
    
    switch obj.guard_type
        case 'kinematics'
            % the function for kinematics guard function will be provided
            % by mathematica-generated MEX file.
            value = obj.guard_func(x) - obj.guard_profile;
        case 'forces'
            % compute constraints forces 
            [~, ~, Fe] = calcDynamics(domain, t, x, model);
            
            % compute the guard function
            value = obj.guard_func(Fe) - obj.guard_profile;
        case 'time'
            % compute guard condition from the time signal
            value = t - obj.guard_profile;
            assert(direction == 1,...
                'Time can ONLY be monotonically increasing.\n');
        case 'phase'
            % compute the current phase variable 'tau'
            tau = domain.tau(x, domain.controller.p);
            value = tau - obj.guard_profile;
            assert(direction == 1,...
                'Tau can ONLY be monotonically increasing.\n');
    end
    
    
end