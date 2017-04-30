function xn = calcDiscreteMap(obj, t, x, varargin)
    % calculates the discrete map of the dynamical system that maps
    % xminus from xplus. Subclasses must implement this method by its
    % own.
    %
    % @note By default, this discrete map will be a Identity map.
    % For specific discrete map, please implement as a subclass of
    % this class
    %
    % Parameters:
    % t: the time instant
    % xminus: the pre-impact states @type colvec
    %
    % Return values:
    % xplus: the post-impact states @type colvec
    
    R = obj.R;
    cstr_name = fieldnames(obj.ImpactConstraints);
    
    nx = obj.numState;
    qminus = x(1:nx);
    dqminus = x(nx+1:end);
    
    if isempty(cstr_name)
        qplus = R*qminus;
        dqplus = R*dqminus;
    else
        q = R*qminus;
        dq = R*dqminus;
        
        %% impact constraints
        cstr = obj.ImpactConstraints;
        n_cstr = numel(cstr_name);
        % determine the total dimension of the holonomic constraints
        cdim = sum([cstr.Dimension]);
        % initialize the Jacobian matrix
        Je = zeros(cdim,nx);
        
        idx = 1;
        for i=1:n_cstr
            c_name = cstr_name{i};
            c_obj = cstr.(c_name);
            % calculate the Jacobian
            [Jh] = calcJacobian(c_obj,q,dq);
            Je(idx:idx+c_obj.Dimension,:) = Jh;
            idx = idx + c_obj.Dimension;
        end
        
        
        % inertia matrix
        De = feval(obj.Mmat.Name, q);
        
        % Compute Dynamically Consistent Contact Null-Space from Lagrange
        % Multiplier Formulation
        DbarInv = Je * (De \ transpose(Je));
        I = eye(nx);
        Jbar = De \ transpose(transpose(DbarInv) \ Je );
        Nbar = I - Jbar * Je;
        
        % Apply null-space projection
        dqplus = Nbar * dq;
        qplus  = q;
        
    end
    
    xn = [qplus; dqplus];
end