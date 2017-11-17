function full_state(nlp, node, bounds)
    % constraints for step length and step width
    
    domain = nlp.Plant;
    x = domain.States.x;
    dx = domain.States.dx;
    
    full_state = [x;dx];
    % knee angle
    full_state_fun = SymFunction(['fullState_',domain.Name], full_state, {x, dx});
    addNodeConstraint(nlp, full_state_fun, {'x', 'dx'}, node, ...
        bounds.constrBounds.full_state.lb, ...
        bounds.constrBounds.full_state.ub,'Linear');
    
end

