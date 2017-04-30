function [xdot, extra] = secondOrderDynamics(obj, t, x, controller, params)
    % calculate the dynamical equation of the second order dynamical system
    %
    % Parameters:
    % t: the time instant @type double
    % x: the states @type colvec
    % controller: the controller @type Controller
    % params: the parameter structure @type struct
    
    
    % extract the state variables into x and dx
    nx = obj.numState;
    x = x(1:nx);
    dx = x(nx+1:end);
    
    % store time and states into object private data for future use
    obj.t_ = t;
    obj.states_.x = x;
    obj.states_.dx = dx;
    
    % compute the mass matrix and drift vector (internal dynamics)
    M = calcMassMatrix(obj, x);
    Fv = calcDriftVector(obj, x,dx);
    
    
    
    
    %% get the external input
    f_ext_name = fieldnames(obj.Inputs.External);
    if ~isempty(f_ext_name)              % if external inputs are defined
        n_ext = length(f_ext_name);
        % initialize the Gv_ext vector
        Gv_ext = zeros(nx,1);
        for i=1:n_ext   
            f_name = f_ext_name{i};
            % get the Gvec function object
            g_fun = obj.Gvec.External.(f_name);
            % call the callback function to get the external input
            f_ext = getExternalInput(obj, f_name, t, x, dx, params);
            % compute the Gvec, and add it up
            Gv_ext = Gv_ext + feval(g_fun.Name,x,f_ext);
            
            % store the external inputs into the object private data
            obj.inputs_.External.(f_name) = f_ext;
        end
    end
    
    
    %% holonomic constraints
    h_cstr_name = fieldnames(obj.HolonomicConstraints);
    if ~isempty(h_cstr_name)           % if holonomic constraints are defined
        h_cstr = obj.HolonomicConstraints;
        n_cstr = numel(h_cstr_name);
        % determine the total dimension of the holonomic constraints
        cdim = sum([h_cstr.Dimension]);
        % initialize the Jacobian matrix
        Je = zeros(cdim,nx);
        Jedot = zeros(cdim,nx);
        
        idx = 1;
        for i=1:n_cstr
            c_name = h_cstr_name{i};
            cstr = h_cstr.(c_name);
            % calculate the Jacobian
            [Jh,dJh] = calcJacobian(cstr,x,dx);
            Je(idx:idx+cstr.Dimension,:) = Jh;
            Jedot(idx:idx+cstr.Dimension,:) = dJh; 
            idx = idx + cstr.Dimension;
        end        
    end
    
    
    %% calculate the constrained vector fields and control inputs
    control_name = fieldnames(obj.Inputs.Control);
    Be = obj.Gmap.Control.(control_name{1});
    Ie    = eye(nx);
    
    
    
    XiInv = Je * (M \ transpose(Je));
    % compute vector fields
    % f(x)
    vfc = [
        dx;
        M \ ((Ie-transpose(Je) * (XiInv \ (Je / M))) * (Fv + Gv_ext) - transpose(Je) * (XiInv \ Jedot * dx))];
    
    
    % g(x)
    gfc = [
        zeros(size(Be));
        M \ (Ie - transpose(Je)* (XiInv \ (Je / M))) * Be];
    
    % compute control inputs
    if nargout > 1
        [u, extra] = calcControl(controller, t, x, dx, vfc, gfc, obj, params);
    else
        u = calcConstrol(controller, t, x, dx, vfc, gfc, obj, params);
    end
    
    Gv_u = Be*u;
    obj.inputs_.Control.(control_name{1}) = u;
    %% calculate constraint wrench of holonomic constraints
    Gv = Gv_ext + Gv_u;
    % Calculate constrained forces
    if ~isempty(h_cstr_name)
        lambda = -XiInv \ (Jedot * dx + Je * (M \ (Fv + Gv)));
        % the constrained wrench inputs
        Gv_c = transpose(Je)*lambda;
        
        % extract and store
        idx = 1;
        for i=1:n_cstr
            c_name = h_cstr_name{i};             
            cstr = h_cstr.(c_name);
            input_name = cstr.InputName;
            obj.inputs_.ConstraintWrench.(input_name) = lambda(idx:idx+cstr.Dimension);
            idx = idx + cstr.Dimension;
        end 
    end
    
    Gv = Gv + Gv_c;
    
    % the system dynamics
    xdot = M \ (Fv + Gv);
    
    
    if nargout > 1
        extra.t       = t;
        extra.x       = x;
        extra.dx      = dx; 
        extra.ddx     = xdot(nx+1:end);
        extra.u       = u;    
        extra.f_ext   = obj.inputs_.External;
        extra.lambda  = obj.inputs_.ConstraintWrench;
    end
end