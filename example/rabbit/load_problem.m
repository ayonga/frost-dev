function nlp = load_problem(model)
    bounds = get_bounds(model);


    num_grid.RightStance = 20;
    num_grid.LeftStance = 20;
    nlp = HybridTrajectoryOptimization('Rabbit_1step',model,num_grid,bounds,...
        'EqualityConstraintBoundary',1e-8,...
        'StackVariable',true,...
        'DerivativeLevel',1);
    
    r_stance = model.Gamma.Nodes.Domain{1};
    
    u = r_stance.Inputs.torque;
    u2r = tovector(norm(u).^2);
    u2r_fun = SymFunction(['torque_' r_stance.Name],u2r,{u});
    addRunningCost(nlp.Phase(getPhaseIndex(nlp,'RightStance')),u2r_fun,{'torque'});
    nlp.update;
end

