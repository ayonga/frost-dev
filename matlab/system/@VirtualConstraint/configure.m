function obj = configure(obj, varargin)
    % compiles the derivatives and Jacobian of the actual/desired
    % outputs functions
    
    % local variables for speed
    rel_deg = obj.RelativeDegree;
    is_holonomic = obj.Holonomic;
    is_state_based = strcmp(obj.PhaseType, 'StateBased');
    model = obj.Model;
    t = SymVariable('t');
    name = [obj.Name '_' model.Name];
    
    % If the relative degree is greater than the highest order of
    % the dynamical system, then we must incorporate the system
    % dynamics for the higher order.
    switch model.Type
        case 'FirstOrder'
            X = model.States.x;
            if rel_deg > 1
                M = model.Mmat;
                F = sum(horzcat(model.Fvec{:}),2);
                dX = M\F;
            else
                dX = model.States.dx;
            end
            
            x = {model.States.x};
        case 'SecondOrder'
            X = [model.States.x;model.States.dx];
            if rel_deg > 2
                M = model.Mmat;
                F = sum(horzcat(model.Fvec{:}),2);
                dX = M\F;
            else
                dX = [model.States.dx;model.States.ddx];
            end
            
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
    ya_fun  = cell(rel_deg+1, 1);
    yd_fun  = cell(rel_deg+1, 1);
    tau_fun = cell(rel_deg+1, 1);
    
    
    % actual outputs
    ya = obj.ya_;
    if is_holonomic
        % ya(x)
        ya_fun{1} = SymFunction(['ya_' name], ya, model.States.x);
    else
        % ya(x,dx)
        ya_fun{1} = SymFunction(['ya_' name], ya, {model.States.x, model.States.dx});
    end
    
    % substitute the time variable with phase variable tau: t -> tau
    tau = obj.tau_;
    no_tau = isempty(tau);
    
    % desired outputs and phase variable
    if is_state_based        
        var = {model.States.x};        
    else
        var = {t};
    end
    
    % configure Desired SymFunction
    if no_tau
        yd = obj.yd_;
    else
        yd = subs(obj.yd_, t, tau);
        % tau(x,p) (becomes tau(x) if p is empty)
        tau_fun{1} = SymFunction(['tau_' name], tau, [var, p]);
    end
    
    % yd(x,a,p) (becomes yd(x,a) if p is empty)
    % yd(t,a,p) (becomes yd(t,a) if p is empty)
    yd_fun{1} = SymFunction(['yd_' name], yd, [var, a, p]);
    
    % y'(x,dx), y''(x,dx),...,y^(N-1)(x,dx)
    if rel_deg > 1
        %% actual outputs
        if is_holonomic
            for i=2:rel_deg
                ya_der = jacobian(ya_fun{i-1},X)*dX;
                ya_fun{i} = SymFunction(['d' num2str(i-1) 'ya_' name], ya_der, x);
            end
        else
            % for non-holonomic constraints, the higher order
            % derivatives are often not regular. Therefore, the
            % user must provides the higher order derivatives
            % explicitly.
            for i=2:rel_deg
                ya_der = varargin{i-1};
                ya_fun{i} = SymFunction(['d' num2str(i-1) 'ya_' name], ya_der, x);
            end
        end
        
        %% desired outputs
        if is_state_based
            for i=2:rel_deg
                yd_der = jacobian(yd_fun{i-1},X)*dX;
                yd_fun{i} = SymFunction(['d' num2str(i-1) 'yd_' name], yd_der, [x, a, p]);
                if ~no_tau
                    tau_der = jacobian(tau_fun{i-1},X)*dX;
                    tau_fun{i} = SymFunction(['d' num2str(i-1) 'tau_' name], tau_der, [x, p]);
                end
            end
        else
            for i=2:rel_deg
                yd_der = jacobian(yd_fun{i-1},t);
                yd_fun{i} = SymFunction(['d' num2str(i-1) 'yd_' name], yd_der, [{t}, a, p]);
                if ~no_tau
                    tau_der = jacobian(tau_fun{i-1},t);
                    tau_fun{i} = SymFunction(['d' num2str(i-1) 'tau_' name], tau_der, [{t}, p]);
                end
            end
            
        end
    end
    
    % y^(N), Jy^(N-1)
    Jya = jacobian(ya_fun{rel_deg},X);    
    ya_fun{rel_deg+1} = SymFunction(['Jd' num2str(rel_deg) 'ya_' name], Jya, x);
    %dX = model.States.dx;
    %ya_der = Jya*dX;
    %ya_fun{rel_deg+2} = SymFunction(['d' num2str(rel_deg) 'ya_' name], ya_der, [x, dx]);
    
    
    if is_state_based
        Jyd = jacobian(yd_fun{rel_deg},X);
        yd_fun{rel_deg+1} = SymFunction(['Jd' num2str(rel_deg) 'yd_' name], Jyd, [x, a, p]);
        % yd_der = Jyd*dX;
        % yd_fun{rel_deg+2} = SymFunction(['d' num2str(rel_deg) 'yd_' name], yd_der, [x, dx, a, p]);
        
        
        if ~no_tau
            Jtau = jacobian(tau_fun{rel_deg},X);
            tau_fun{rel_deg+1} = SymFunction(['Jd' num2str(rel_deg) 'tau_' name], Jtau, [x, p]);
        end
        % tau_der = Jtau*dX;
        % tau_fun{rel_deg+1} = SymFunction(['d' num2str(rel_deg) 'tau_' name], tau_der, [x, dx, p]);
    else     
        yd_der = jacobian(yd_fun{rel_deg},t);
        yd_fun{rel_deg+1} = SymFunction(['Jd' num2str(rel_deg) 'yd_' name], yd_der, [{t}, a, p]);
        
        if ~no_tau
            Jtau = jacobian(tau_fun{rel_deg},t);
            tau_fun{rel_deg+1} = SymFunction(['Jd' num2str(rel_deg) 'tau_' name], Jtau, [{t}, p]);
        end
        
        % 
        % yd_fun{rel_deg+2} = SymFunction(['d' num2str(rel_deg) 'yd_' name], yd_der, [t, a]);
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