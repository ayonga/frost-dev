function foot_clearance(nlp, bounds, frame)
    % constraints for swing foot clearance
    
    domain = nlp.Plant;
    x = domain.States.x;
    
    
    
    
    pos = getCartesianPosition(domain, frame);    
    constraint_func = SymFunction(['foot_clearance_',domain.Name], pos(3), {x});
    
    % Foot Clearance Middle
    numNode = nlp.NumNode;
    %     addNodeConstraint(nlp, constraint_func, {'x'}, 'first', 0, 0, 'Nonlinear');
    %     addNodeConstraint(nlp, constraint_func, {'x'}, floor(numNode/2)+1, ...
    %         bounds.constrBounds.foot_clearance.lb, ...
    %         bounds.constrBounds.foot_clearance.ub,'Nonlinear');
    %     addNodeConstraint(nlp, constraint_func, {'x'}, 'last', 0, 0, 'Nonlinear');

    addNodeConstraint(nlp, 'all', constraint_func, {'x'}, 0, 0.15);
    
    % first and last nodes
    lb = 0;
    ub = 0;
    nlp.updateConstrProp(constraint_func.Name, [1,numNode], 'lb', lb, 'ub', ub);
    
    
    % 1/2 cycle
    lb = bounds.constrBounds.foot_clearance.lb;
    ub = bounds.constrBounds.foot_clearance.ub;
    nlp.updateConstrProp(constraint_func.Name, floor(numNode/2)+1, 'lb', lb, 'ub', ub);
    
end

