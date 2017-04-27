function [sol] = simulate(obj, t0, x0, tf, controller, params, options)
    % Simulate the dynamical system
    %
    % Parameters: 
    % t0: the starting time instant @type double
    % x0: the initial states @type colvec
    % tf: the terminating time instant @type double
    % controller: the controller for the dynamical system @type Controller
    % params: extra parameters @type struct
    % options: simulation options of hybrid system @type struct
    
    
    if isempty(t0)
        % default initial time
        t0 = 0;
    else
        validateattributes(t0,{'double'},...
            {'scalar','positive','real'},...
            'ContinuousDynamics.simulate','t0',2);
    end
    
    
    
    first_order_system = strcmp(obj.Type, 'FirstOrder');
    
    if first_order_system
        nx = obj.numState;
    else
        % second order system
        nx = 2*obj.numState;
    end
    
    
    if isempty(x0)
        % default zero initial condition
        warning('Starting the simulation with zero initial condition!')
        x0 = zeros(nx,1);
    else
        % validate the initial states
        validateattributes(x0,{'double'},...
            {'vector','numel',nx,'real'},...
            'ContinuousDynamics.simulate','x0',3);
    
    end
    
    
    if isempty(tf)
        % default terminal time
        tf = t0 + 10;
    else
        validateattributes(tf,{'double'},...
            {'scalar','positive','real'},...
            'ContinuousDynamics.simulate','tf',4);
    end
    
    % validate the controller object
    if ~isempty(controller)
        validateattributes(controller, {'Controller'},...
            {},'ContinuousDynamics.simulate','controller',5);
    end
    % validate the parameter structure
    if ~isempty(params)
        validateattributes(params, {'struct'},...
            {},'ContinuousDynamics.simulate','params',6);
    end
    
    
    % configure the ODE
    odeopts = odeset('MaxStep', 1e-2,'RelTol',1e-6,'AbsTol',1e-6);
    % parse simulation options
    if ~isempty(options)
        validateattributes(options, {'struct'},...
            {},'ContinuousDynamics.simulate','options',7);
        odeopts = struct_overlay(odeopts, options);
    end
        
    obj.preProcess(controller, params);
    
    % run the forward simulation
    sol = ode45(@(t, x) calcDynamics(obj, t, x, controller, params), ...
        [t0, tf], x0, odeopts);
        
    obj.postProcess(sol, controller, params);
    
end