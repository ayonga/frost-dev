function right_stance_constraints(nlp, bounds, varargin)
    
    domain = nlp.Plant;
    
    
    % relative degree 1 output
    domain.VirtualConstraints.velocity.imposeNLPConstraint(nlp, bounds.velocity.ep, 0);
    % tau boundary [0,1]
    tau = domain.VirtualConstraints.velocity.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','pvelocity'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pvelocity'}, 'last', 1, 1, 'Nonlinear');
    
    % relative degree 2 outputs
    domain.VirtualConstraints.position.imposeNLPConstraint(nlp, [bounds.position.kp,bounds.position.kd], [1,1]);
    % tau boundary [0,1]
    tau = domain.VirtualConstraints.position.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','pposition'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pposition'}, 'last', 1, 1, 'Nonlinear');
    
    
    
    % output boundary 
    y_pos = domain.VirtualConstraints.position;
    y_bound_idx = str_indices({'RightTorsoRoll','RightTorsoPitch','LeftLegRoll'},y_pos.OutputLabel);
    
    y_bound = y_pos.ActualOutput(y_bound_idx);
    
    y_bound_fun = SymFunction(['output_boundary_',domain.Name], y_bound, {domain.States.x});
    addNodeConstraint(nlp, y_bound_fun, {'x'}, 'all', [-0.2,-0.1,-0.2],[0.2,0.2,0.05],'Linear');
    
    % impact velocity
    J_left_sole = getBodyJacobian(domain, domain.ContactPoints.LeftSole);
    v_left_sole = J_left_sole(1:3,:)*domain.States.dx;
    v_left_sole_fun = SymFunction(['impact_velocity_',domain.Name], v_left_sole, {domain.States.x,domain.States.dx});
    addNodeConstraint(nlp, v_left_sole_fun, {'x','dx'}, 'last', [-0.1,-0.05,-0.5],[0.4,0.04,-0.2],'Nonlinear');
    
end