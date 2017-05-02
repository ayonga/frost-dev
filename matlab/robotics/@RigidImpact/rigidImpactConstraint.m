function nlp = rigidImpactConstraint(obj, nlp, src, tar, bounds, varargin)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    % src_nlp: the NLP of the source domain system
    % @type TrajectoryOptimization
    % tar_nlp: the NLP of the target domain system
    % @type TrajectoryOptimization
    % bounds: a struct data contains the boundary values @type struct
    
    R = obj.R;
    
    % the configuration only depends on the relabeling matrix
    x = obj.States.x;
    xn = obj.States.xn;
    x_map = SymFunction(['xDiscreteMap' obj.Name],R*x-xn,{x,xn});
    
    addNodeConstraint(nlp, x_map, {'x','xn'}, 'first', 0, 0, 'Linear');
    cstr_name = fieldnames(obj.ImpactConstraints);
    dx = obj.States.dx;
    dxn = obj.States.dxn;
    
    % the velocities determined by the impact constraints
    if isempty(cstr_name)
        % by default, identity map
        
        dx_map = SymFunction(['dxDiscreteMap' obj.Name],R*dx-dxn,{dx,dxn});
        
        addNodeConstraint(nlp, dx_map, {'dx','dxn'}, 'first', 0, 0, 'Linear');
    else
        %% impact constraints
        cstr = obj.ImpactConstraints;
        n_cstr = numel(cstr_name);
        nx  = length(x);
        % initialize the Jacobian matrix
        Gvec = zeros(nx,1);
        deltaF = cell(1, n_cstr);
        input_name = cell(1,n_cstr);
        for i=1:n_cstr
            c_name = cstr_name{i};
            input_name{i} = cstr.(c_name).InputName;
            Gvec = Gvec + obj.Gvec.ConstraintWrench.(input_name{i});
            deltaF{i} = obj.Inputs.ConstraintWrench.(input_name{i});
        end
        
        % D(q) -> D(q^+)
        M = subs(obj.Mmat, x, xn);
        Gvec = subs(Gvec, x, xn);
        % D(q^+)*(dq^+ - R*dq^-) = sum(J_i'(q^+)*deltaF_i)
        delta_dq = M*(dxn - R*dx) - Gvec;
        dx_map = SymFunction(['dxDiscreteMap' obj.Name],delta_dq,[{dx},{xn},{dxn},deltaF]);
        
        addNodeConstraint(nlp, dx_map, ['dx','xn', 'dxn', input_name], 'first', 0, 0, 'Linear');
        
    end
    
end
