function obj = simulate(obj, new_options)
    % Run the simulation of the hybrid dynamical system
    %
    %
    
    if nargin > 1
       obj.options.simOpts = struct_overlay(obj.options.simOpts,new_options);
    end
    
    ncycle = obj.options.simOpts;
    
    if(isempty(obj.options.simOpts.startingVertex))
        v0 = obj.gamma.vertices{1};
    else
        v0 = obj.options.simOpts.startingVertex;
        assert(any(strcmp(obj.gamma.vertices,v0)),...
            'The vertex %s does not exist in the graph.',v0);
    end
    
    
    domain0 = obj.domains(strcmp(obj.gamma.vertices,v0));   
    x0 = getInitialStates(domain0);
    t0 = 0;
    
    % trajectory recorders
    calcs = cell(ncycle,1);
    v = v0;
    
    for k=1:ncycle
        domain_flag = 'first';        
        while v ~= v0 && ~strcmp(domain_flag,'first')
            domain_flag = [];
            cur_domain = obj.domains(strcmp(obj.gamma.vertices,v));  
            e = getEdgeBySource(v);
            cur_guard = obj.guards(strcmp(obj.gamma.edges,e));   
            
            ref = Recorder();
            
            odeopts = odeset(obj.options.odeOpts,...
                'OutputFcn', @(t,x,flag)outputfcn(t,x,flag,ref), ...
                'Events', @(t, x) checkGuard(cur_guard, t, x, cur_domain, model));          
            
            
            
            sol = ode113(@(t, x) calcDynamics(cur_domain, t, x, model, ref), ...
                [t0, t0+100], x0, odeopts);
            
            % Compute reset map at the guard
            t_f = sol.x(end);
            x_f = sol.y(:,end);
            
            % log the simulation data
            dynamics(t_f, x_f, cur_domain, ref);
            updateLastRecord(ref);
            
            
            
            x0  = calcResetMap(cur_guard, model, x_f);
            % Store calculations
            calcs{k} = {calcs{k},horzcat_fields(cell2mat(ref.calcs))};
            
            v_next = getTarget(obj.gamma,v);
            
            v = v_next;
        end
    end
    
    obj.traj = calcs;
    
    
    
    
end