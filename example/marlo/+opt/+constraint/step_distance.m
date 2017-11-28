function step_distance(nlp, bounds)
    % constraints for step length and step width
    
    domain = nlp.Plant;
    x = domain.States.x;
    
    [right_foot_frame] = sys.frames.RightFoot(domain);
    [left_foot_frame] = sys.frames.LeftFoot(domain);
    right_foot = getCartesianPosition(domain, right_foot_frame);  
    left_foot = getCartesianPosition(domain, left_foot_frame);
    constraint = tomatrix(left_foot(1:2) - right_foot(1:2));
    constraint_func = SymFunction(['step_distance_',domain.Name], constraint, {x});
    lb = [bounds.constrBounds.stepWidth.lb
        bounds.constrBounds.stepLength.lb];
    ub = [bounds.constrBounds.stepWidth.ub
        bounds.constrBounds.stepLength.ub];
    addNodeConstraint(nlp, constraint_func, {'x'}, 'first', lb, ub, 'NonLinear');
    
    
    wt = 0.3662;
    lb = [-wt-0.01
        0-0.01];
    ub = [-wt+0.01
        0+0.01];
    addNodeConstraint(nlp, constraint_func, {'x'}, floor(nlp.NumNode/2)+1, lb, ub, 'NonLinear');
end

