function right_impact_constraints(nlp, src, tar, bounds, varargin)
    
    plant = nlp.Plant;
    
    % fist call the class method
    plant.rigidImpactConstraint(nlp, src, tar, bounds, varargin{:});
    
    % Don't need time continuity constraint
    removeConstraint(nlp,'tContDomain');

    % the relabeling of joint coordiante is no longer valid
    removeConstraint(nlp,'xDiscreteMapRightImpact');
    
    % the configuration only depends on the relabeling matrix
    R = plant.R;
    x = plant.States.x;
    xn = plant.States.xn;
    x_diff = R*x-xn;
    x_map = SymFunction(['xDiscreteMap' plant.Name],x_diff(3:end),{x,xn});
    
    addNodeConstraint(nlp, x_map, {'x','xn'}, 'first', 0, 0, 'Linear');
    
end