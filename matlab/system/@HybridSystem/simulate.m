function obj = simulate(obj)
    % Run the simulation of the hybrid dynamical system
    %
    %
    
   
    
    
    
    
    
    for k=1:num_cycle
        domain_flag = 'first';        
        while ~strcmp(v,v0) || strcmp(domain_flag,'first')
            domain_flag = [];
            cur_domain = obj.domains(strcmp(obj.gamma.vertices,v));  
            e = getEdgeBySource(obj.gamma,v);
            cur_guard = obj.guards(strcmp({obj.gamma.edges.name},e));   
            
            ref = Recorder();
            
            odeopts = odeset(obj.options.ode_options,...
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