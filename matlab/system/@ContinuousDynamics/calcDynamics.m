function [xdot, extra] = calcDynamics(obj, t, x, controller, params)
    % calculate the dynamical equation dx 
    %
    %
    
    is_second_order = strcmp(obj.Type,'SecondOrder');
    nx = obj.numState;
    if is_second_order
        x = x(1:nx);
        dx = x(nx+1:end);
    else
        x = x(1:nx);
    end
    
    % compute the natural dynamics part
    M = obj.calcMassMatrix(x);
    Fvec = obj.calcDriftVector(x,dx);
    
    %% get the external input
    f_external_name = fieldnames(obj.Inputs.External);
    if ~isempty(f_external_name)
        % if external inputs are defined
        n_external = length(f_external_name);
        % initialize the Gvec_External
        Gvec_external = zeros(nx,1);
        for i=1:n_external   
            f_name = f_external_name{i};
            % get the function object
            g_fun = obj.Gvec.External.(f_name);
            % the external input should be provided via params argument
            if isfield(params,f_name)
                f_external = params.(f_name);
            else
                % if not, use prompt
                prompt = sprintf('Please enter the external force %s? ',f_name);
                f_external = input(prompt);
            end
            % compute the Gvec, and add it up
            Gvec_external = Gvec_external + feval(g_fun.Name,x,f_external);
        end
    end
    
    
    %% holonomic constraints
    cstr_wrench_name = fieldnames(obj.HolonomicConstraints);
    if ~isempty(cstr_wrench_name)
        % if defined, first compute the Jacobian matrices of them
        n_cstr = length(cstr_wrench_name);
        Je = zeros(0,nx);
        Jedot = zeros(0,nx);
        for i=1:n_cstr
            c_name = cstr_wrench_name{i};
            cstr = obj.HolonomicConstraints.(c_name);
            if is_second_order
                [Jh_tmp,dJh_tmp] = calcConstraint(cstr,x,dx);
            else
                if cstr.DerivativeOrder == 2
                    der_order = 2;
                    [Jh_tmp,dJh_tmp] = calcConstraint(cstr,x);
                else
                    der_order = 1;
                    [Jh_tmp] = calcConstraint(cstr,x);
                    dJh_tmp = Jh_tmp;
                end
            end
            Je = [Je;Jh_tmp]; %#ok<AGROW>
            Jedot = [Jedot;dJh_tmp]; %#ok<AGROW>
        end        
    end
    
    
    %% calculate the constrained vector fields and control inputs
    control_name = fieldnames(obj.Inputs.Control);
    Be = obj.Gmap.Control.(control_name{1});
    Ie    = eye(nx);
    
    
    
    if is_second_order
        XiInv = Je * (M \ transpose(Je));
        % compute vector fields
        % f(x)
        vfc = [
            dx;
            M \ ((Ie-transpose(Je) * (XiInv \ (Je / M))) * (Fvec + Gvec_external) - transpose(Je) * (XiInv \ Jedot * dx))];
        
        
        % g(x)
        gfc = [
            zeros(size(Be));
            M \ (Ie - transpose(Je)* (XiInv \ (Je / M))) * Be];
        
        % compute control inputs
        if nargin > 1
            [u, extra] = calcControl(controller, t, x, dx, vfc, gfc, obj, params);
        else
            u = calcConstrol(controller, t, x, dx, vfc, gfc, obj, params);
        end
        
        Gvec_control = Be*u;
    else
        if der_order == 2
            XiInv = Jedot * (M \ transpose(Je));
        else
            XiInv = Je * (M \ transpose(Je));
        end
        % compute vector fields
        % f(x)
        vfc = [
            M \ ((Ie - transpose(Je) * (XiInv \ (Jedot / M))) * (Fvec + Gvec_external))];
        
        
        % g(x)
        gfc = [
            M \ (Ie - transpose(Je)* (XiInv \ (Jedot / M))) * Be];
        
        % compute control inputs
        if nargin > 1
            [u, extra] = calcControl(controller, t, x, vfc, gfc, obj);
        else
            u = calcConstrol(controller, t, x, vfc, gfc, obj);
        end
        
        Gvec_control = Be*u;
    end
    
    %% calculate constraint wrench of holonomic constraints
    FG = Fvec + Gvec_external + Gvec_control;
    % Calculate constrained forces
    if ~isempty(cstr_wrench_name)
        if is_second_order
            lambda = -XiInv \ (Jedot * dx + Je * (De \ FG));
        else
            lambda = -XiInv \ (Jedot * (De \ FG));
        end
        % the final vector field
        FG = FG + transpose(Je)*lambda;
    else
        lambda = [];
    end
    
    
    
    % the system dynamics
    xdot = M \ FG;
    
    
    if nargin > 1
        extra.t    = t;
        extra.x    = x;
        extra.dx   = dx;
        extra.vfc  = vfc;
        extra.gfc  = gfc;
        extra.u    = u;    
        extra.Fe   = f_external;
        extra.lambda   = lambda;
        extra.FG  = FG;
        extra.M   = M;
        extra.Je    = Je;
        extra.Jedot = Jedot;
        % extra.domain = cur_domain;
        % extra.control = cur_control;
    end
end