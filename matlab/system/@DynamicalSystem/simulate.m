function sol = simulate(obj, options, varargin)
    % Simulate the dynamical system
    %
    % Parameters: 
    % options: simulation options of hybrid system @type struct
    %
    %
    % Optional fields of options:
    % x0: the initial states of the system, zero if not specified
    % @type colvec
    
    % parse simulation options
    if nargin < 2
        options = struct;
    end
    
    first_order_system = strcmp(obj.Type, 'FirstOrder');
    
    if first_order_system
        nx = obj.NumState;
    else
        % second order system
        nx = 2*obj.NumState;
    end
    
    if isfield(options, 'x0')
        x0 = options.x0;
        validateattributes(x0,{'double'},...
            {'vector','numel',nx,'real'},...
            'DynamicalSystem.simulate','x0');
    else
        warning('Starting the simulation with zero initial condition!')
        x0 = zeros(nx,1);
    end
            
    
    % clear previous results
    obj.Flow = [];
    
    if isfield(options,'tf')
        tf = options.tf;
    else
        tf = 10;
    end
        
    % configure the ODE
    odeopts = odeset('MaxStep', 1e-2,'RelTol',1e-6,'AbsTol',1e-6);
    if isfield(options,'odeopts')
        odeopts = struct_overlay(odeopts, options.odeopts);
    end
        
        
        
    sol = ode45(@(t, x) calcDynamics(obj, t, x, varargin{:}), ...
        [0, tf], x0, odeopts);
        
        
        
    if ~isfield(options, 'samplefreq')
        n_sample = length(sol.x);
        calcs = cell(1,n_sample);
        for i=1:n_sample
            [~,extra] = calcDynamics(obj,  sol.x(i), sol.y(:,i), varargin{:});
            value = checkGuard(obj, sol.x(i), sol.y(:,i));
            extra.guard_value = value;
            calcs{i} = extra;
        end
    else
        fs = options.samplefreq;
        [tspan,xsample] = even_sample(sol.x,sol.y,fs);
        n_sample = length(tspan);
        calcs = cell(1,n_sample+1);
        for i=1:n_sample+1
            [~,extra] = calcDynamics(obj,  tspan(i), xsample(:,i), varargin{:});
            value = options.Guard(tspan(i), xsample(:,i));
            extra.guard_value = value;
            calcs{i} = extra;
        end
    end
        
    obj.Flow = horzcat_fields([calcs{:}]);
end