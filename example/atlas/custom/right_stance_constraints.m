function right_stance_constraints(nlp, bounds, varargin)
    
    plant = nlp.Plant;
    
    plant.VirtualConstraints.velocity.imposeNLPConstraint(nlp, bounds.velocity.ep, 0);
    
    tau = plant.VirtualConstraints.velocity.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','pvelocity'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pvelocity'}, 'last', 1, 1, 'Nonlinear');
    
    
    plant.VirtualConstraints.position.imposeNLPConstraint(nlp, [bounds.position.kp,bounds.position.kd], [1,1]);
    tau = plant.VirtualConstraints.position.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','pposition'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pposition'}, 'last', 1, 1, 'Nonlinear');
    
    
    
end