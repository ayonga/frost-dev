function [system] = LoadSystem(model, load_path)
    % Load the hybrid system model 
    
    if nargin < 2
        load_path = [];
    end
    
    
    rightStance = sys.domains.RightStance(model, load_path);
    rightStance.CustomNLPConstraint = @opt.callback.RightStanceConstraints;
    leftStance = sys.domains.LeftStance(model, load_path);
    leftStance.CustomNLPConstraint = @opt.callback.LeftStanceConstraints;
    
    leftImpact = RigidImpact('LeftImpact', leftStance, rightStance.EventFuncs.leftfoot_height); % To leftStance
    leftImpact.CustomNLPConstraint = @opt.callback.LeftImpactConstraints;
    
    rightImpact = RigidImpact('RightImpact', rightStance, leftStance.EventFuncs.rightfoot_height); % To rightStance
    rightImpact.CustomNLPConstraint = @opt.callback.RightImpactConstraints;


    system = HybridSystem('atrias');
    system = addVertex(system, 'RightStance', 'Domain', rightStance);
    system = addVertex(system, 'LeftStance', 'Domain', leftStance);

    srcs = {'RightStance'
        'LeftStance'};

    tars = {'LeftStance'
        'RightStance'};

    system = addEdge(system, srcs, tars);
    system = setEdgeProperties(system, srcs, tars, ...
        'Guard', {leftImpact, rightImpact});
    
    
end

