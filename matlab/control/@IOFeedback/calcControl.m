function [u, extra] = calcControl(obj, t, x, vfc, gfc, domain, params)
    % Computes the classical input-output feedback linearization
    % control law for virtual constraints
    %
    % Parameters:
    % t: the time instant @type double
    % x: the states @type colvec
    % vfc: the vector field f(x) @type colvec
    % gfc: the vector field g(x) @type colvec
    % domain: the continuous domain @type Domain
    % params: the control parameters @type struct
    %
    % Return values:
    % u: the computed torque @type colvec
    % extra: additional computed data @type struct
    
    nx = domain.numState;
    if strcmp(domain.Type,'SecondOrder')        
        q = x(1:nx);
        dq = x(nx+1:end);
    else
        q = x;
        dq = []; % will not affect any computation
    end
    
    
    y = struct2array(domain.VirtualConstraints);
    ny = length(y);
    y_a = cell(ny,1);
    y_d = cell(ny,1);
    tau = cell(ny,1);
    
    % total dimension of the virtual constraints
    dim_y = sum([y.Dimension]);
    % partial derivative of the highest order of derivative (y^n-1) w.r.t.
    % the state variable 'x'
    DLfy = zeros(dim_y,nx);   % A = DLfy*gfc; Lf = DLfy*vfc;
    mu = zeros(dim_y,1);    % The derivatives mu = k(1) y + k(2) y' + ... k(n) y^(n-1)
    idx = 1; % indexing of outputs
    for i=1:ny
        y_i = y{i};
        
        % returns y, y', y'', y^(n-1), Jy^n-1
        y_a{i} = cell(1,y_i.RelativeDegree+1);
        y_d{i} = cell(1,y_i.RelativeDegree+1);
        tau{i} = cell(1,y_i.RelativeDegree+1);
        
        % calculate the actual outputs
        [y_a{i,:}] = calcActual(y_i,q,dq);
        
        % extract the parameter values 
        output_param = y_i.OutputParamName; % desired output parameters
        phase_param  = y_i.PhaseParamName;  % phase variable parameters
        
        
        if isfield(params,output_param)
            a = params.(output_param);
        else
            error('The parameter %s has not been specified in the ''params'' argument.\n', output_param);
        end
        
        if ~isempty(phase_param)
            if isfield(params,phase_param)
                p = params.(phase_param);
            else
                error('The parameter %s has not been specified in the ''params'' argument.\n', phase_param);
            end
        else
            p = [];
        end
        % calculate the desired outputs
        [y_d{i,:}] = calcDesired(y_i, t, q, dq, a, p);
        % calculate the phase variable
        [tau{i,:}] = calcPhaseVariable(y_i, t, q, dq, p);
        
        
        
        
        % control gain (k0,k1,...kN-1) for the feedback term 
        control_param = ['k',y_i.Name];
        if isfield(params,control_param)
            K = params.(control_param);
            assert(length(K) == y_i.RelativeDegree,...
                'The expected length of the control gain parameter ''k'' is: %d\n', y_i.RelativeDegree);
        else
            error('The control gain %s has not been specified in the ''params'' argument.\n', control_param);
        end
        
        % stack the partial derivatives of all outputs
        y_indices = linspace(idx,idx+y_i.Dimension-1,1);
        DLfy(y_indices,:) = y_a{i,end} - y_d{i,end};
        for j=1:y_i.RelativeDegree
            mu(y_indices) = mu(y_indices) + K(j)*(y_a{i,j}-y_d{i,j});
        end
        % update the starting index for the next outpu
        idx = idx+y_i.Dimension;
    end
        
        
    
    
    
    % decoupling matrix
    A_mat  = DLfy*gfc;
    % feedforward term
    Lf_mat = DLfy*vfc;

    
    % feedforward controller 
    u_ff = - A_mat \ Lf_mat;
    % feedback controller
    u_fb = -A_mat \ mu;

    u = u_ff + u_fb;

    

    if nargout > 1
        extra = struct;
        extra.mu = mu;
        extra.ya = y_a;
        extra.yd = y_d;
        extra.tau = tau;
        extra.u_ff = u_ff;
        extra.u_fb = u_fb;
        extra.u = u;
    end

end