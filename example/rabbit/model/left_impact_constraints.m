function left_impact_constraints(nlp, varargin)
    
    plant = nlp.Plant;
        
    % Don't need time continuity constraint
    removeConstraint(nlp,'tContDomain');

    % the relabeling of joint coordiante is no longer valid
    removeConstraint(nlp,['xDiscreteMap_' plant.Name]);
    
    % the configuration only depends on the relabeling matrix
    R = plant.R;
    x = plant.States.x;
    xn = plant.States.xn;
    x_diff = R*x-xn;
    x_map = SymFunction(['xDiscreteMap_' plant.Name],x_diff(2:end),{x,xn});
    
    addNodeConstraint(nlp, 'first', x_map, {'x','xn'}, 0, 0);
    
end