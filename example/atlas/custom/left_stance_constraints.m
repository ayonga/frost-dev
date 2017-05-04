function left_stance_constraints(nlp, bounds, varargin)
    
    domain = nlp.Plant;
    
    domain.VirtualConstraints.velocity.imposeNLPConstraint(nlp, bounds.velocity.ep, 0);
    
    tau = domain.VirtualConstraints.velocity.PhaseFuncs{1};
    
    addNodeConstraint(nlp, tau, {'x','pvelocity'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pvelocity'}, 'last', 1, 1, 'Nonlinear');
    
    
    domain.VirtualConstraints.position.imposeNLPConstraint(nlp, [bounds.position.kp,bounds.position.kd], [1,1]);
    tau = domain.VirtualConstraints.position.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','pposition'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pposition'}, 'last', 1, 1, 'Nonlinear');
    
    
    % output boundary 
    y_pos = domain.VirtualConstraints.position;
    y_bound_idx = str_indices({'LeftTorsoRoll','LeftTorsoPitch','RightLegRoll',...
         'RightFootCartX', 'RightFootCartY', 'RightFootCartZ'},y_pos.OutputLabel);
    
    y_bound = y_pos.ActualOutput(y_bound_idx);
    lb = [-0.2,-0.1,-0.2,0,0,0]';
    ub = [0.2,0.2,0.05,0,0,0]';
    y_bound_fun = SymFunction(['output_boundary_',domain.Name], y_bound, {domain.States.x});
    addNodeConstraint(nlp, y_bound_fun, {'x'}, 'all', lb, ub,'Linear');
    
    % impact velocity
    J_right_sole = getBodyJacobian(domain, domain.ContactPoints.RightSole);
    v_right_sole = J_right_sole(1:3,:)*domain.States.dx;
    v_right_sole_fun = SymFunction(['impact_velocity_',domain.Name], v_right_sole, {domain.States.x,domain.States.dx});
    addNodeConstraint(nlp, v_right_sole_fun, {'x','dx'}, 'last', [-0.1,-0.05,-0.5],[0.4,0.04,-0.2],'Nonlinear');
end