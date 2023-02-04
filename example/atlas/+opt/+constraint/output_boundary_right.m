function output_boundary_right(nlp, bounds)
    % constraints for impact velocities
    
    domain = nlp.Plant;
    x = domain.States.x;
    
    % output boundary 
    y_pos = domain.VirtualConstraints.Outputs;
    y_bound_idx = str_indices({'RightTorsoRoll','RightTorsoPitch','LeftLegRoll',...
         'LeftFootCartX', 'LeftFootCartY', 'LeftFootCartZ'},y_pos.OutputLabel);
    
    y_bound = y_pos.ActualOutput([y_bound_idx{:}]);
    lb = bounds.constrBounds.outputLimit.lb;
    ub = bounds.constrBounds.outputLimit.ub;
    y_bound_fun = SymFunction(['output_boundary_',domain.Name], y_bound, {x});
    addNodeConstraint(nlp, 'all', y_bound_fun, {'x'}, lb, ub);
    
end

