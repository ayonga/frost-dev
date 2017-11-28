function RightImpactConstraints(nlp, src, tar, bounds, varargin)
    plant = nlp.Plant;
    
    % no need to be time-continuous
    removeConstraint(nlp,'tContDomain');
    
    % first call the class method (calling impact model since it no longer
    % applies if we have a custom function)
    plant.rigidImpactConstraint(nlp, src, tar, bounds, varargin{:});
    
    % the relabeling/periodicity of joint coordiante is no longer valid
    % (this only affects position peridicity, velocity still applies)
    removeConstraint(nlp,'xDiscreteMapRightImpact');
    
    % Readding Periodicity (ignoring first 6 coordinates)
    R = plant.R;
    x = plant.States.x;
    xn = plant.States.xn;
    x_diff = R*x-xn;
    x_map = SymFunction(['xPartialDiscreteMap' plant.Name],x_diff(7:end),{x,xn});
    
    addNodeConstraint(nlp, x_map, {'x','xn'}, 'first', 0, 0, 'Linear');
end
