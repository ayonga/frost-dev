function right_impact_constraints(nlp, src, tar, bounds, varargin)
    
    
    % no need to be time-continuous
    removeConstraint(nlp,'tContDomain');
    
    plant = nlp.Plant;
    
    % fist call the class method
    plant.rigidImpactConstraint(nlp, src, tar, bounds, varargin{:});
    
    % the relabeling of joint coordiante is no longer valid
    removeConstraint(nlp,'xDiscreteMapRightImpact');
    
    
    
    R = plant.R;
    
    % the configuration only depends on the relabeling matrix
    x = plant.States.x;
    xn = plant.States.xn;
    x_diff = R*x-xn;
    x_diff(7:end)
    x_map = SymFunction(['xDiscreteMap' plant.Name],x_diff(7:end),{x,xn});
    
    addNodeConstraint(nlp, x_map, {'x','xn'}, 'first', 0, 0, 'Linear');
    
end