function [x_post] = updateStates(obj, model, x_pre, delta)
    % Updates the system states using the reset map associated with the
    % discontinuous transition to the current domain to get the initial
    % states of the current domain.
    %   
    % 
    % Parameters: 
    %    model: the robot model of type RigitBodyModel
    %    qe_pre: pre-guard joint configuration @type colvec
    %    dqe_pre: pre-guard velocities @type colvec
    %    delta: the reset map option @type struct
    %
    % Return values:
    %    qe_post: post-guard joint configuration @type colvec
    %    dqe_post: post-guard velocities @type colvec
    
    qe_pre  = x_pre(model.qeIndices);
    dqe_pre = x_pre(model.dqeIndices); 
    % the joint configuration remains the same
    qe_post = qe_pre;
    
    % compute the impact map if the domain transition involves a rigid impact
    if delta.ApplyImpact
        % jacobian of impact constraints
        Je = feval(obj.HolonomicConstr.Funcs.Jac, qe_pre);
        
        % inertia matrix
        De = calcNaturalDynamics(model, qe_pre, dqe_pre);
        
        % Compute Dynamically Consistent Contact Null-Space from Lagrange
        % Multiplier Formulation
        DbarInv = Je * (De \ transpose(Je));
        I = eye(size(De));
        Jbar = De \ transpose(transpose(DbarInv) \ Je );
        Nbar = I - Jbar * Je;
        
        % Apply null-space projection
        dqe_post = Nbar * dqe_pre;
        %         nImpConstr = size(Je,1);
        %         A = [De -Je'; Je zeros(nImpConstr)];
        %         b = [De*dqe_pre; zeros(nImpConstr,1)];
        %         y = A\b;
        %
        %         ImpF = y((model.n_dofs+1):end);
        %         dqe_pre = y(model.qe_indices);
    else
        dqe_post = dqe_pre;
        
    end
    
    % if swapping the stance/non-stance foot, multiply with
    % 'delta.CoordinateRelabelMatrix'
    if ~isempty(delta.CoordinateRelabelMatrix)
        qe_post  = delta.CoordinateRelabelMatrix * qe_post;
        dqe_post = delta.CoordinateRelabelMatrix * dqe_post;
    end

    x_post = [qe_post; dqe_post];
 
end
