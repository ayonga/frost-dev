function [tn, xn,lambda] = calcDiscreteMap(obj, t, x, varargin)
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
    % x: the pre-impact states @type colvec
    %
    % Return values:
    % tn: the time after reset @type double
    % xn: the post-impact states @type colvec
    % lambda: the impulsive wrench @type struct
    
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
        cstr = struct2array(obj.ImpactConstraints);
        n_cstr = length(cstr);
        % determine the total dimension of the holonomic constraints
        cdim = sum([cstr.Dimension]);
        % initialize the Jacobian matrix
        Je = zeros(cdim,nx);
        
        idx = 1;
        for i=1:n_cstr
            c_obj = cstr(i);
            cstr_indices = idx:idx+c_obj.Dimension-1;
            
            % calculate the Jacobian
            [Jh] = calcJacobian(c_obj,q,dq);
            Je(cstr_indices,:) = Jh;
            idx = idx + c_obj.Dimension;
        end
        
        
        % inertia matrix
        De = calcMassMatrix(obj,q);
        
        % % Compute Dynamically Consistent Contact Null-Space from Lagrange
        % % Multiplier Formulation
        %         DbarInv = Je * (De \ transpose(Je));
        %         I = eye(nx);
        %         Jbar = De \ transpose(transpose(DbarInv) \ Je );
        %         Nbar = I - Jbar * Je;
        % % Apply null-space projection
        %         dqplus = Nbar * dq;
        
        
        nImpConstr = size(Je,1);
        A = [De -Je'; Je zeros(nImpConstr)];
        b = [De*dq; zeros(nImpConstr,1)];
        y = A\b;
        
        ImpF = y((obj.numState+1):end);
        
        idx = 1;
        for i=1:n_cstr
            c_obj = cstr(i);
            cstr_indices = idx:idx+c_obj.Dimension-1;
            
            % calculate the Jacobian
            lambda.(c_obj.InputName) = ImpF(cstr_indices);
            idx = idx + c_obj.Dimension;
        end
        
        
        dqplus = y(1:obj.numState);
        
        
        qplus  = q;
        
    end
    
    tn = t;
    xn = [qplus; dqplus];
end