function [x_post,ImpF] = calcResetMap(obj, model, tar_domain, x_pre)
    % Calculate the reset map associated with the discontinuous dynamics
    %   
    % 
    % Parameters: 
    %    model: the rigid body model
    %    tar_domain: the target domain of the edge
    %    x_pre: pre guard states
    %
    % Return values:
    %    x_post: post guard states
    %    ImpF: the impulsive constrained forces/moments
    

    
    % x_pre -> [qe_pre; dqe_pre]
    qe_pre    = x_pre(model.qeIndices);
    dqe_pre   = x_pre(model.dqeIndices);
    
    
    % compute the impact map if the domain transition involves a rigid impact
    if obj.options.apply_rigid_impact
        % jacobian of impact constraints
        Je  = tar_domain.holConstrJac(x_pre);
        
        % inertia matrix
        De = calcNaturalDynamics(model,x);
        
        % Compute Dynamically Consistent Contact Null-Space from Lagrange
        % Multiplier Formulation
        %         DbarInv = Je * (De \ transpose(Je));
        %         I = eye(obj.nDof);
        %         Jbar = De \ transpose(transpose(DbarInv) \ Je );
        %         Nbar = I - Jbar * Je;
        
        % Apply null-space projection
        %         dqe_plus = Nbar * dqe_pre;        
        nImpConstr = size(Je,1);
        A = [De -Je'; Je zeros(nImpConstr)];
        b = [De*dqe_pre; zeros(nImpConstr,1)];
        y = A\b;
        
        ImpF = y((model.nDof+1):end);
        dqe_pre = y(model.qeIndices);
        
        
    else
        ImpF = [];
    end
    
    % if swapping the stance/non-stance foot, multiply with
    % 'footSwappingMatrix'
    if obj.options.relabel_coordinates
        qe_pre  = model.coordRelabel * qe_pre;
        dqe_pre = model.coordRelabel * dqe_pre;
    end

    % construct the post impact states
    x_post = [...
        qe_pre;
        dqe_pre]; 
end
