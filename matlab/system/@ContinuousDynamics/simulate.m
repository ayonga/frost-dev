function [sol] = simulate(obj, t0, x0, tf, controller, params, eventnames, options, varargin)
    % Simulate the dynamical system
    %
    % Parameters: 
    % t0: the starting time instant @type double
    % x0: the initial states @type colvec
    % tf: the terminating time instant @type double
    % controller: the controller for the dynamical system @type Controller
    % params: extra parameters @type struct
    % eventnames: the name of eventnames to be used @type cellstr
    % options: simulation options of hybrid system @type struct
    
    
    if isempty(t0)
        % default initial time
        t0 = 0;
    else
        validateattributes(t0,{'double'},...
            {'scalar','nonnegative','real'},...
            'ContinuousDynamics.simulate','t0',2);
    end
    
    
    if strcmp(obj.Type, 'FirstOrder')
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
        tf = t0 + 100;
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
        obj.setParamValue(params);
    end
    
    % configure the ODE options
    odeopts = odeset('MaxStep', 1e-2,'RelTol',1e-6,'AbsTol',1e-6);
    
    % configure the event functions
    if ~isempty(eventnames)
        events_list = fieldnames(obj.EventFuncs);
        if isempty(events_list)
            warning('There is no event function defined for the system.');
        else
            if ~iscell(eventnames), eventnames = {eventnames}; end
            assert(iscellstr(eventnames),...
                'The list of eventnames name must be a character vector or a cell array of character vectors.');
            event_indices = zeros(numel(eventnames),1);
            for i=1:numel(eventnames)
                idx = str_index(eventnames{i}, events_list);
                
                if isempty(idx)
                    warning('The event function (%s) is not defined for the system.',eventnames{i});
                else
                    event_indices(i) = idx;
                end
            end
            if any(event_indices)
                
                eventfuncs = cellfun(@(x)obj.EventFuncs.(x),events_list(event_indices~=0),'UniformOutput',false);
                eventfuncs = vertcat(eventfuncs{:});
                odeopts.Events = @(t, x) checkGuard(obj, t, x, controller, params, eventfuncs);
            end
        end
    end
    % parse simulation options
    if ~isempty(options)
        validateattributes(options, {'struct'},...
            {},'ContinuousDynamics.simulate','options',7);
        odeopts = struct_overlay(odeopts, options);
    end
    
    % pre-process
    obj.PreProcess(obj, controller, params, varargin{:});
    
    % run the forward simulation
    sol = ode45(@(t, x) calcDynamics(obj, t, x, controller, params), ...
        [t0, tf], x0, odeopts);
        
    % post-process
    obj.PostProcess(obj, sol, controller, params, varargin{:});
    
    % record the simulated trajectory
    % clear previous results
    obj.Flow = [];
    
    n_sample = length(sol.x);
    calcs = cell(1,n_sample);
    for i=1:n_sample
        [~,extra] = calcDynamics(obj,  sol.x(i), sol.y(:,i), controller, params);
        calcs{i} = extra;
    end
    
    calcs_full = horzcat_fields([calcs{:}]);
    obj.Flow = calcs_full;
end