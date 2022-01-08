function [xdot] = firstOrderDynamics(obj, t, x, controller, params, logger)
    % calculate the dynamical equation of the first order dynamical system
    %
    % Parameters:
    % t: the time instant @type double
    % x: the states @type colvec
    % controller: the controller @type Controller
    % params: the parameter structure @type struct
    % logger: the data logger object @type SimLogger
    %
    % Return values:
    % xdot: the derivative of the system states @type colvec
    
    % extract the state variables into x and dx
    nx = obj.Dimension;
    
    % store time and states into object private data for future use
    obj.t_ = t;
    obj.states_.x = x;
    
    % compute the mass matrix and drift vector (internal dynamics)
    M = calcMassMatrix(obj, x);
    Fv = calcDriftVector(obj, x);
    
    
    
    
    %% get the external input
    % initialize the Gv_ext vector
    Gv = zeros(nx,1);
    input_names = fieldnames(obj.Inputs);
    n_ext = length(input_names);
    if n_ext > 0
        for i=1:n_ext   
            f_name = input_names{i};
            input = obj.Inputs.(input_names{i});
            if ~isempty(input.CallbackFunction)
                f = input.CallbackFunction(input,obj,t,x,logger);
            end
            % compute the Gvec, and add it up
            Gmap = feval(input.Gmap.Name,x);
            Gv = Gv + Gmap*f;
            
            % store the external inputs into the object private data
            obj.inputs_.(f_name) = f;
        end
    end
    
    dx_free = M\(-Fv+Gv);
    
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
            [Jh,dJh] = calcJacobian(cstr,x);
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
        dx = dx_free;
    else
        Xi = Je * (M \ transpose(Je));
        lambda = -Xi \ (Jedot * dq + Je * dx_free);
        P = eye(nx) - M\(transpose(Je)/Xi)*Je;
        %         ddq = M\(-Fv+Gv+Je'*lambda);
        dx = P*dx_free;
        for i=1:n_cstr
            cstr = h_cstr(i);
            cstr_indices = idx:idx+cstr.Dimension-1;
            input_name = cstr.f_name;
            obj.inputs_.(input_name) = lambda(cstr_indices);
            idx = idx + cstr.Dimension;
        end
    end
    
    % the system dynamics
    xdot = dx;
    obj.states_.dx = dx;
    
    if ~isempty(logger)
        calc = logger.calc;

        calc.t       = t;
        calc.states  = obj.states_;
        calc.inputs  = obj.inputs_;
        logger.calc  = calc;
    end
end