function left_impact_constraints(nlp, src, tar, bounds, varargin)
    
    % foot clearance: u_nsf_RightStance
    % this should be domain constraints, but u_nsf_RightStance as event
    % condition, imposed after the domain constraints
    event_cstr_name = 'u_nsf_RightStance';
    numNode = src.NumNode;
    updateConstrProp(src,event_cstr_name,floor(numNode/4),'lb',0.02);
    updateConstrProp(src,event_cstr_name,floor(numNode/2),'lb',0.06);
    updateConstrProp(src,event_cstr_name,floor(3*numNode/4),'lb',0.02);


    % no need to be time-continuous
    removeConstraint(nlp,'tContDomain');
    
    plant = nlp.Plant;
    
    % fist call the class method
    plant.rigidImpactConstraint(nlp, src, tar, bounds, varargin{:});
    
    % the relabeling of joint coordiante is no longer valid
    removeConstraint(nlp,'xDiscreteMapLeftImpact');
    
    
    
    R = plant.R;
    
    % the configuration only depends on the relabeling matrix
    x = plant.States.x;
    xn = plant.States.xn;
    x_diff = R*x-xn;
    x_map = SymFunction(['xDiscreteMap' plant.Name],x_diff(4:end),{x,xn});
    
    addNodeConstraint(nlp, x_map, {'x','xn'}, 'first', 0, 0, 'Linear');
    
end