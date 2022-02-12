function obj = configure(obj, load_path, varargin)
    % compiles the derivatives and Jacobian of the actual/desired
    % outputs functions
    
    % local variables for speed
    rel_degree = obj.RelativeDegree;
    is_holonomic = obj.IsHolonomic;
    is_state_based = strcmp(obj.PhaseType, 'StateBased');
    model = obj.Model;
    t = SymVariable('t');
    name = [obj.Name '_' model.Name];
    
    % If the relative degree is greater than the highest order of
    % the dynamical system, then we must incorporate the system
    % dynamics for the higher order.
    if isempty(load_path)
        switch model.Type
            case 'FirstOrder'
                X = model.States.x;
                if rel_degree > 1
                    M = model.Mmat;
                    F = sum(horzcat(model.Fvec{:}),2);
                    dX = tomatrix(M\F);
                else
                    dX = model.States.dx;
                end
            case 'SecondOrder'
                X = [model.States.x;model.States.dx];
                if rel_degree > 2
                    M = model.Mmat;
                    F = sum(horzcat(model.Fvec{:}),2);
                    dX = tomatrix(M\F);
                else
                    dX = [model.States.dx;model.States.ddx];
                end
        end
    end
    
    switch model.Type
        case 'FirstOrder'
            x = {model.States.x};
        case 'SecondOrder'            
            x = {model.States.x, model.States.dx};
    end
    % store as cell variable, so they can be catcanated into cell
    % array easily.
    a = {SymVariable(tomatrix(obj.OutputParams(:)))};   
    if ~isempty(obj.PhaseParams)
        p = {SymVariable(tomatrix(obj.PhaseParams(:)))};
    else
        p = {};
    end
    
    % preallocation
    ya_fun  = cell(rel_degree+1, 1);
    yd_fun  = cell(rel_degree+1, obj.NumSegment);
    tau_fun = cell(rel_degree+1, 1);
    
    
    % actual outputs
    ya = obj.ya_;
    if is_holonomic
        % ya(x)
        deps = model.States.x;
        ya_fun{1} = SymFunction(['ya_' name], ya, deps);            
    else
        % ya(x,dx)
        deps = {model.States.x, model.States.dx};
        ya_fun{1} = SymFunction(['ya_' name], ya, deps);
    end
    
    
    % desired outputs and phase variable
    if is_state_based        
        var = {model.States.x};        
    else
        var = {t};
    end
    
    
    % substitute the time variable with phase variable tau: t -> tau
    tau = obj.tau_;
    no_tau = isempty(tau);
    if ~no_tau
        % tau(x,p) (becomes tau(x) if p is empty)
        tau_fun{1} = SymFunction(['tau_' name], tau, [var, p]);
    end
    
    
    
    % configure Desired SymFunction
    for s = 1:obj.NumSegment
        yd_name = ['yd_s',num2str(s),'_', name];
        if no_tau
            yd = tomatrix(obj.yd_{s});
        else
            if isempty(load_path)
                yd = tomatrix(subs(obj.yd_{s}, t, tau));
            else
                yd = SymExpression([]);
                yd = load(yd, load_path, yd_name);
            end
        end
        % yd(x,a,p) (becomes yd(x,a) if p is empty)
        % yd(t,a,p) (becomes yd(t,a) if p is empty)
        yd_fun{1, s} = SymFunction(yd_name, yd, [var, a, p]);
    end
    
    
    
    
    % y'(x,dx), y''(x,dx),...,y^(N-1)(x,dx)
    if rel_degree > 1
        
        if isempty(load_path)
            %% actual outputs
            if is_holonomic
                for i=2:rel_degree
                    ya_der = jacobian(ya_fun{i-1},X)*dX;
                    ya_fun{i} = SymFunction(['d' num2str(i-1) 'ya_' name], ya_der, x);
                end
            else
                % for non-holonomic constraints, the higher order
                % derivatives are often not regular. Therefore, the
                % user must provides the higher order derivatives
                % explicitly.
                for i=2:rel_degree
                    ya_der = varargin{i-1};
                    ya_fun{i} = SymFunction(['d' num2str(i-1) 'ya_' name], ya_der, x);
                end
            end
            
            %% phase variable
            if ~no_tau
                if is_state_based
                    tau_der = jacobian(tau_fun{i-1},X)*dX;
                    tau_fun{i} = SymFunction(['d' num2str(i-1) 'tau_' name], tau_der, [x, p]);
                else
                    tau_der = jacobian(tau_fun{i-1},t);
                    tau_fun{i} = SymFunction(['d' num2str(i-1) 'tau_' name], tau_der, [{t}, p]);
                end                
            end
            %% desired outputs
            for s = 1:obj.NumSegment
                if is_state_based
                    for i=2:rel_degree
                        yd_der = jacobian(yd_fun{i-1, s},X)*dX;
                        yd_fun{i, s} = SymFunction(['d' num2str(i-1) 'yd_s',num2str(s),'_', name], yd_der, [x, a, p]);
                    end
                else
                    for i=2:rel_degree
                        yd_der = jacobian(yd_fun{i-1, s},t);
                        yd_fun{i, s} = SymFunction(['d' num2str(i-1) 'yd_s',num2str(s),'_', name], yd_der, [{t}, a, p]);
                    end
                    
                end
            end
            
        else % load from external files
            for i=2:rel_degree
                ya_fun{i} = SymFunction(['d' num2str(i-1) 'ya_' name], [], x);
                ya_fun{i} = load(ya_fun{i}, load_path);
            end
            
            if ~no_tau
                if is_state_based
                    tau_deps = [x, p];
                else
                    tau_deps = [{t}, p];
                end
                for i=2:rel_degree
                    tau_fun{i} = SymFunction(['d' num2str(i-1) 'tau_' name], [], tau_deps);
                    tau_fun{i} = load(tau_fun{i}, load_path);
                end
            end
            
            if is_state_based
                yd_deps = [x, a, p];
            else
                yd_deps = [{t}, a, p];
            end
                
            for s = 1:obj.NumSegment
                for i=2:rel_degree
                    yd_fun{i, s} = SymFunction(['d' num2str(i-1) 'yd_s',num2str(s),'_', name], [], yd_deps);
                    yd_fun{i, s} = load(yd_fun{i, s}, load_path);                    
                end
            end
        end
    end
    
    % y^(N), Jy^(N-1)
    if isempty(load_path)
        Jya = jacobian(ya_fun{rel_degree},X);
        ya_fun{rel_degree+1} = SymFunction(['Jd' num2str(rel_degree) 'ya_' name], Jya, x);
    else
        ya_fun{rel_degree+1} = SymFunction(['Jd' num2str(rel_degree) 'ya_' name], [], x);
        ya_fun{rel_degree+1} = load(ya_fun{rel_degree+1}, load_path);
    end
    %dX = model.States.dx;
    %ya_der = Jya*dX;
    %ya_fun{rel_deg+2} = SymFunction(['d' num2str(rel_deg) 'ya_' name], ya_der, [x, dx]);
    if ~no_tau
        if isempty(load_path)
            if is_state_based
                Jtau = jacobian(tau_fun{rel_degree},X);
                tau_fun{rel_degree+1} = SymFunction(['Jd' num2str(rel_degree) 'tau_' name], Jtau, [x, p]);
            else
                Jtau = jacobian(tau_fun{rel_degree},t);
                tau_fun{rel_degree+1} = SymFunction(['Jd' num2str(rel_degree) 'tau_' name], Jtau, [{t}, p]);
            end
        else
            if is_state_based
                tau_fun{rel_degree+1} = SymFunction(['Jd' num2str(rel_degree) 'tau_' name], [], [x, p]);
                tau_fun{rel_degree+1} = load(tau_fun{rel_degree+1}, load_path);
            else
                tau_fun{rel_degree+1} = SymFunction(['Jd' num2str(rel_degree) 'tau_' name], [], [{t}, p]);
                tau_fun{rel_degree+1} = load(tau_fun{rel_degree+1}, load_path);
            end
        end
    end 
    
    
    if isempty(load_path)
        for s = 1:obj.NumSegment
            if is_state_based
                Jyd = jacobian(yd_fun{rel_degree, s},X);
                yd_fun{rel_degree+1, s} = SymFunction(['Jd' num2str(rel_degree) 'yd_s',num2str(s),'_', name], Jyd, [x, a, p]);
            else
                yd_der = jacobian(yd_fun{rel_degree, s},t);
                yd_fun{rel_degree+1, s} = SymFunction(['Jd' num2str(rel_degree) 'yd_s',num2str(s),'_', name], yd_der, [{t}, a, p]);
            end
        end
    else
        for s = 1:obj.NumSegment
            if is_state_based
                yd_fun{rel_degree+1, s} = SymFunction(['Jd' num2str(rel_degree) 'yd_s',num2str(s),'_', name], [], [x, a, p]);
                yd_fun{rel_degree+1, s} = load(yd_fun{rel_degree+1, s}, load_path);
                
            else
                yd_fun{rel_degree+1, s} = SymFunction(['Jd' num2str(rel_degree) 'yd_s',num2str(s),'_', name], [], [{t}, a, p]);
                yd_fun{rel_degree+1, s} = load(yd_fun{rel_degree+1, s}, load_path);
                
            end
        end
    end
            
    obj.ActualFuncs = ya_fun;
    obj.DesiredFuncs = yd_fun;
    
    
    obj.ActualFuncsName_ = cellfun(@(f)f.Name, ya_fun,'UniformOutput',false);
    obj.DesiredFuncsName_ = cellfun(@(f)f.Name, yd_fun,'UniformOutput',false);
    if ~no_tau
        obj.PhaseFuncs = tau_fun;
        obj.PhaseFuncsName_ = cellfun(@(f)f.Name, tau_fun,'UniformOutput',false);
    end
end