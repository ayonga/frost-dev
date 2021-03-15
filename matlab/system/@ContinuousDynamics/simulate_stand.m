function [sol, params] = simulate_stand(obj, t0, x0, tf, controller, params, logger, eventnames, options, solver,alpha,min,max)
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
    
    if nargin > 1 && ~isempty(t0)
        validateattributes(t0,{'double'},...
            {'scalar','nonnegative','real'},...
            'ContinuousDynamics.simulate','t0',2);        
    else
        % default initial time
        t0 = 0;
    end
    
    
    if strcmp(obj.Type, 'FirstOrder')
        nx = obj.numState;
    else
        % second order system
        nx = 2*obj.numState;
    end
    if nargin > 2 && ~isempty(x0)
        % validate the initial states
        validateattributes(x0,{'double'},...
            {'vector','numel',nx,'real'},...
            'ContinuousDynamics.simulate','x0',3);        
    else
        % default zero initial condition
        warning('Starting the simulation with zero initial condition!')
        x0 = zeros(nx,1);
    end
    
    
    if nargin > 3 && ~isempty(tf)
        validateattributes(tf,{'double'},...
            {'scalar','positive','real'},...
            'ContinuousDynamics.simulate','tf',4);        
    else
        % default terminal time
        tf = t0 + 100;
    end
    
    % validate the controller object
    if nargin > 4 && ~isempty(controller)
        validateattributes(controller, {'Controller'},...
            {},'ContinuousDynamics.simulate','controller',5);
    else
        controller = [];
    end
    % validate the parameter structure
    if nargin > 5 && ~isempty(params)
        validateattributes(params, {'struct'},...
            {},'ContinuousDynamics.simulate','params',6);
        obj.setParamValue(params);
    else
        params = [];
    end
    
    % configure the ODE options
    odeopts = odeset('MaxStep', 1e-2,'RelTol',1e-6,'AbsTol',1e-6);
    
    if nargin > 6 && ~isempty(logger)
        validateattributes(logger, {'SimLogger'},...
            {},'ContinuousDynamics.simulate','options',7);
        odeopts = odeset(odeopts, 'OutputFcn', @(t,x,flag)outputfcn(t,x,flag,logger));
        logger.initialize();
        logger.static.params     = obj.params_;
    else
        logger = [];
    end
    
    if nargin > 8 && ~isempty(options)
        validateattributes(options, {'struct'},...
            {},'ContinuousDynamics.simulate','options',9);
        odeopts = odeset(odeopts, options);
    end

    if nargin > 9 && ~isempty(solver)
        validateattributes(solver, {'function_handle'},...
            {},'ContinuousDynamics.simulate','solver',10);
    else
        solver = @ode45;
    end

    % pre-process
    if ~isempty(obj.PreProcess)
        params = obj.PreProcess(obj, t0, x0, controller, params);
        obj.setParamValue(params);
    end    
    
    % configure the event functions
    if nargin > 7 && ~isempty(eventnames)
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
                
                eventfuncs = cellfun(@(x)obj.EventFuncs.(x),events_list(event_indices),'UniformOutput',false);
                eventfuncs = vertcat(eventfuncs{:});
                odeopts = odeset(odeopts, 'Events',@(t, x) checkGuard_stand(obj, t, x, controller, params, eventfuncs,alpha,min,max));
            end
        end
    end
    
    % run the forward simulation
    if strcmp(obj.Name,'stand')
        'pause';
    end
    sol = solver(@(t, x) calcDynamics_stand(obj, t, x, controller, params, logger,alpha,min,max), ...
        [t0, tf], x0, odeopts);
    
    % calculate the dynamics at the guard 
    if isfield(sol,'xe') && ~isempty(sol.xe)
%         tf_try=ceil(sol.xe);
%         tf_round=round(sol.xe);
%         if abs(tf_round-sol.xe) >0.3
%             if strcmp(obj.Name, 'RightSS') && mod(tf_try,2) ~=1
%                 pause
%                 fprintf('something is wrong right transition')
%             elseif strcmp(obj.Name, 'LeftSS') && mod(tf_try,2) ==1
%                 pause
%                 fprintf('something is wrong: left transition')
%             end
%             sol_try=solver(@(t, x) calcDynamics(obj, t, x, controller, params, logger), ...
%                 [sol.xe, tf_try], sol.ye, odeopts);
%             sol_try.xe=sol_try.x(end);
%             sol_try.ye=sol_try.y(:,end);
%             sol_try.ie=1;
%             sol=sol_try;
%         end
        calcDynamics_stand(obj, sol.xe, sol.ye, controller, params, logger,alpha,min,max);
        updateLastLog(logger);
    end
    % post-process
    if ~isempty(obj.PostProcess)
        params = obj.PostProcess(obj, sol, controller, params);
        obj.setParamValue(params);
    end
    
    
end