function yaw_start(nlp, bounds)
    
    
    domain = nlp.Plant;
    
     % yaw initialized zero
    x = domain.States.x;
    yaw = x('BaseRotZ');
    yaw_fun = SymFunction(['yaw_',domain.Name], yaw, {x});
    addNodeConstraint(nlp, yaw_fun, {'x'}, 'first',  ...
        bounds.constrBounds.yaw_initial.lb, ...
        bounds.constrBounds.yaw_initial.ub,'Linear');
    
end

