function [xdot] = robotDynamics(obj, t, x, logger)
    % calculate the dynamical equation of the second order dynamical system
    %
    % Parameters:
    % t: the time instant @type double
    % x: the states @type colvec
    % logger: the data logger object @type SimLogger
    %
    % Return values:
    % xdot: the derivative of the system states @type colvec
    
    if nargin < 4
        logger = [];
    end
    
    
    % extract the state variables into x and dx
    nx = obj.Dimension;
    q = x(1:nx);
    dq = x(nx+1:end);
    
    % store time and states into object private data for future use
    obj.t_ = t;
    obj.states_.x = q;
    obj.states_.dx = dq;
    
    % compute the mass matrix and drift vector (internal dynamics)
    M = calcMassMatrix(obj, q);
    Fv = calcDriftVector(obj, q, dq);
    
    
    
    
    %% get the external input
    % initialize the Gv_ext vector
    Gv = zeros(nx,1);
    input_names = fieldnames(obj.Inputs);
    n_input = length(input_names);
    if n_input > 0
        for i=1:n_input   
            f_name = input_names{i};
            input = obj.Inputs.(input_names{i});
            if isempty(input.Gmap) || isempty(input.CallbackFunction)
                continue;
            end
            
            % call the callback function
            f = input.CallbackFunction(input,obj,t,x,logger);
            
            % compute the Gvec, and add it up
            Gmap = feval(input.Gmap.Name,q);
            Gv = Gv + Gmap*f;
            
            % store the external inputs into the object private data
            obj.inputs_.(f_name) = f;
        end
    end
    
    ddq_free = M\(-Fv+Gv);
    
    %% holonomic constraints
    h_cstr_name = fieldnames(obj.HolonomicConstraints);
    if ~isempty(h_cstr_name)           % if holonomic constraints are defined
        h_cstr = struct2array(obj.HolonomicConstraints);
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
    
    if isempty(Je)
        ddq = ddq_free;
    else
        Xi = Je * (M \ transpose(Je));
        lambda = -Xi \ (Jedot * dq + Je * ddq_free);
        P = eye(nx) - M\(transpose(Je)/Xi)*Je;
        %         ddq = M\(-Fv+Gv+Je'*lambda);
        ddq = P*ddq_free;
        for i=1:n_cstr
            cstr = h_cstr(i);
            cstr_indices = idx:idx+cstr.Dimension-1;
            input_name = cstr.f_name;
            obj.inputs_.(input_name) = lambda(cstr_indices);
            idx = idx + cstr.Dimension;
        end
    end
    
    %     if isempty(Je)
    %         ddq = ddq_free;
    %     else
    %         gamma = Jedot*dq;
    %         tol = 1e-8;
    %         ddq = ddq_free;
    %         n_c = size(Je,1);
    %         lambda = zeros(n_c,1);
    %         lambda_k = zeros(n_c,1);
    %         mu = 1e-6;
    %         L = lagrangian(ddq, ddq_free, lambda, lambda_k, M, Je, gamma, mu, alpha);
    %         while L > tol
    %             K = [-mu*eye(n_c), Je;
    %                 Je', M];
    %             b = [-gamma + alpha - mu*lambda_k;
    %                 M*ddq_free];
    %
    %
    %         end
    %
    %     end
    
    % the system dynamics
    xdot = [dq; 
        ddq];
    obj.states_.ddx = ddq;
    
    % log data
    if ~isempty(logger)
        calc = logger.calc;
        calc.t       = t;
        calc.states  = obj.states_;
        calc.inputs  = obj.inputs_;
        logger.calc  = calc;
    end
    
    
    %     function L = lagrangian(ddq, ddq_free, lambda, lambda_k, M, Je, gamma, mu, alpha)
    %         if nargin < 9
    %             alpha = zeros(size(ddq));
    %         end
    %         delta_ddq = ddq - ddq_free;
    %         delta_lambda = lambda - lambda_k;
    %         L = (1/2)*sqrt(delta_ddq'*M*delta_ddq) + lambda'*(Je*ddq + gamma - alpha) - ...
    %             (mu/2)*sqrt(delta_lambda'*delta_lambda);
    %     end
end

