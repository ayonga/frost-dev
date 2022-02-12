function [u] = computed_torques(input, model, t, x, logger)
    % input-output linearization control
    
    nx = model.Dimension;
    q = x(1:nx);
    dq = x(nx+1:end);

    M = calcMassMatrix(model, q);
    Fv = calcDriftVector(model, q, dq);
    
    h_cstr_name = fieldnames(model.HolonomicConstraints);
    if ~isempty(h_cstr_name)           % if holonomic constraints are defined
        h_cstr = struct2array(model.HolonomicConstraints);
        n_cstr = length(h_cstr);
        % determine the total dimension of the holonomic constraints
        cdim = sum([h_cstr.Dimension]);
        % initialize the Jacobian matrix
        Je = zeros(cdim,nx);
        Jedot = zeros(cdim,nx);
        
        idx = 1;
        for i=1:n_cstr
            cstr = h_cstr(i);
            
            % calculate the Jacobian
            [Jh,dJh] = calcJacobian(cstr,q,dq);
            cstr_indices = idx:idx+cstr.Dimension-1;
                    
            Je(cstr_indices,:) = Jh;
            Jedot(cstr_indices,:) = dJh; 
            idx = idx + cstr.Dimension;
        end 
    else
        Je = [];
        Jedot = [];        
    end
    
    Be = gmap_torque(q);
    Ie    = eye(nx);
    
    
    XiInv = Je * (M \ transpose(Je));
    % compute vector fields
    % f(x)
    vfc = [
        dq;
        M \ ((Ie-transpose(Je) * (XiInv \ (Je / M))) * (Fv) - transpose(Je) * (XiInv \ Jedot * dq))];
    
    
    % g(x)
    gfc = [
        zeros(size(Be));
        M \ (Ie - transpose(Je)* (XiInv \ (Je / M))) * Be];
    
    y_obj = model.VirtualConstraints.Outputs;
    a = input.Params.a;
    p = input.Params.p;
    ya = calcActual(y_obj, q, dq);
    yd = calcDesired(y_obj, t, q, dq, a, p);
    
    DLfy = ya{end};
    ddy = yd{end};
    kp = input.Params.kp;
    kd = input.Params.kd;
    mu = kp*(ya{1} - yd{1}) + kd*(ya{2} - yd{2});
    
    % decoupling matrix
    A_mat  = DLfy*gfc;
    % feedforward term
    Lf_mat = DLfy*vfc;
    u_ff = - A_mat \ (Lf_mat - ddy);
    u_fb = -A_mat \ mu;
            
    u = u_ff + u_fb;
    
    
    calc = logger.calc;
    calc.u_ff = u_ff;
    calc.u_fb = u_fb;
    calc.mu = mu;
    
end

