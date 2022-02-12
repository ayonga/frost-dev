function [sol, logger] = simulate(obj, x0, t0, tf, eventnames, options)
    % Simulate the dynamical system
    %
    % Parameters: 
    % t0: the starting time instant @type double
    % x0: the initial states @type colvec
    % tf: the terminating time instant @type double
    % controller: the controller for the dynamical system @type Controller
    % params: extra parameters @type struct    
    % logger: the data logger object @type SimLogger
    % eventnames: the name of eventnames to be used @type cellstr
    % options: simulation options of hybrid system @type struct
    % solver: the ODE solver @type function_handle
    %
    % Return values:
    % sol: a structure contains the integration result of the ODE solver
    % @type struct
    
    arguments
        obj ContinuousDynamics
        x0 (:,1) double {mustBeNonNan,mustBeReal} = zeros(2*obj.Dimension,1)
        t0 = 0
        tf = 100
        eventnames (:,1) cell {iscellstr(eventnames)} = {}
        options struct = struct()
    end
    
    
    logger = SimLogger(obj);
    
    % configure the ODE options
    odeopts = odeset('MaxStep', 1e-2,'RelTol',1e-5,'AbsTol',1e-5);
    odeopts = odeset(odeopts, 'OutputFcn', @(t,x,flag)outputfcn(t,x,flag,logger));
    odeopts = odeset(odeopts, options);
   
    if isfield(options, 'solver')
        solver = options.solver;
    else
        solver = @ode45;
    end
    
    % configure the event functions
    if ~isempty(eventnames)
        events_list = fieldnames(obj.EventFuncs);
        defined_events = struct2array(obj.EventFuncs);
        if isempty(defined_events)
            warning('There is no event function defined for the system.');
        else
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
                eventfuncs = defined_events(event_indices);
                odeopts = odeset(odeopts, 'Events',@(t, x) checkGuard(obj, t, x, eventfuncs, logger));
            end
        end
    else
        event_indices = [];
    end
    
    
    % pre-process
    if ~isempty(obj.PreIntegrationCallback)
        obj.PreIntegrationCallback(obj, t0, x0);
    end
    obj.t0 = t0;
    
    % run the forward simulation
%     tf = params.ptime(1);
    sol = solver(@(t, x) obj.calcDynamics(obj, t, x, logger), ...
        [t0, tf], x0, odeopts);
    
    % calculate the dynamics at the guard 
    if isfield(sol,'xe') && ~isempty(sol.xe)
        obj.calcDynamics(obj, sol.xe, sol.ye,logger);
        if any(event_indices)  
            checkGuard(obj, sol.xe, sol.ye, eventfuncs, logger);
        end
        updateLastLog(logger);
        disp('Impact Detected!')
    else
        sol.xe = sol.x(end);
        sol.ye = sol.y(:,end);
        %       if tf == params.ptime(1)
        sol.ie = 1;
        %       end
        obj.calcDynamics(obj, sol.xe, sol.ye, logger);
        if any(event_indices)  
            checkGuard(obj, sol.xe, sol.ye, eventfuncs, logger);
        end
        updateLastLog(logger);
        disp('End of Phase!')
    end
    % post-process
    if ~isempty(obj.PostIntegrationCallback)
        obj.PostIntegrationCallback(obj, sol.x(end), sol.y(:,end));
    end
    
    
end