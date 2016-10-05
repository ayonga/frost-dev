function [value, isterminal, direction] = checkGuard(obj, t, x, domain, model)
    % Detect the guard condition (event trigger)

    % substract 'q' from 'x' 
    %     qe = x(model.qeIndices);
    %     dqe = x(model.dqeIndices);

    direction  = obj.guardDir;
    isterminal = 1;
    
    
    switch obj.guardType
        case 'kinematics'
            % the function for kinematics guard function will be provided
            % by mathematica-generated MEX file.
            value = obj.guardFunc(x) - obj.guardProfile;
        case 'forces'
            % compute constraints forces 
            [~, ~, Fe] = calcDynamics(domain, t, x, model);
            
            % compute the guard function
            value = obj.guardFunc(Fe) - obj.guardProfile;
        case 'time'
            % compute guard condition from the time signal
            value = t - obj.guardProfile;
            assert(direction == 1,...
                'Time can ONLY be monotonically increasing.\n');
        case 'phase'
            % compute the current phase variable 'tau'
            tau = domain.tau(x, domain.controller.p);
            value = tau - obj.guardProfile;
            assert(direction == 1,...
                'Tau can ONLY be monotonically increasing.\n');
    end
    
    
end