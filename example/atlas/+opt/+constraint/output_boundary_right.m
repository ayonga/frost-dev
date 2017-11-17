function output_boundary_right(nlp, bounds)
    % constraints for impact velocities
    
    domain = nlp.Plant;
    x = domain.States.x;
    
    % output boundary 
    y_pos = domain.VirtualConstraints.position;
    y_bound_idx = str_indices({'RightTorsoRoll','RightTorsoPitch','LeftLegRoll',...
         'LeftFootCartX', 'LeftFootCartY', 'LeftFootCartZ'},y_pos.OutputLabel);
    
    y_bound = y_pos.ActualOutput(y_bound_idx);
    lb = bounds.constrBounds.outputLimit.lb;
    ub = bounds.constrBounds.outputLimit.ub;
    y_bound_fun = SymFunction(['output_boundary_',domain.Name], y_bound, {x});
    addNodeConstraint(nlp, y_bound_fun, {'x'}, 'all', lb, ub,'Linear');
    
end

