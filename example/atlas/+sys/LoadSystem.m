function [system] = LoadSystem(model, load_path)
    % Load the hybrid system model 
    
    if nargin < 2
        load_path = [];
    end
    
    
    rightStance = sys.domains.RightStance(model, load_path);
    leftStance = sys.domains.LeftStance(model, load_path);
    
    leftImpact = RigidImpact('LeftImpact', rightStance, 'leftFootHeight'); % To leftStance
    leftImpact.addImpactConstraint(struct2array(leftStance.HolonomicConstraints), load_path);
    
    rightImpact = RigidImpact('RightImpact', leftStance, 'rightFootHeight'); % To rightStance
    rightImpact.addImpactConstraint(struct2array(rightStance.HolonomicConstraints), load_path);
    
    io_control  = IOFeedback('IO');

    system = HybridSystem('atrias');
    system = addVertex(system, 'RightStance', 'Domain', rightStance, ...
        'Control', io_control);
    system = addVertex(system, 'LeftStance', 'Domain', leftStance, ...
        'Control', io_control);

    srcs = {'RightStance'
        'LeftStance'};

    tars = {'LeftStance'
        'RightStance'};

    system = addEdge(system, srcs, tars);
    system = setEdgeProperties(system, srcs, tars, ...
        'Guard', {leftImpact, rightImpact});
    
    
end

