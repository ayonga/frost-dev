function [system] = LoadSystem(model, load_path)
    % Load the hybrid system model 
    
    if nargin < 2
        load_path = [];
    end
    
    
    rightStance = sys.domains.RightStance(model, load_path);
    rightStance.UserNlpConstraint = @opt.callback.RightStanceConstraints;
    leftStance = sys.domains.LeftStance(model, load_path);
    leftStance.UserNlpConstraint = @opt.callback.LeftStanceConstraints;
    
    leftImpact = RigidImpact('LeftImpact', leftStance, 'leftFootHeight'); % To leftStance
    leftImpact.addImpactConstraint(struct2array(leftStance.HolonomicConstraints), load_path);
    leftImpact.UserNlpConstraint = @opt.callback.LeftImpactConstraints;
    
    rightImpact = RigidImpact('RightImpact', rightStance, 'rightFootHeight'); % To rightStance
    rightImpact.addImpactConstraint(struct2array(rightStance.HolonomicConstraints), load_path);
    rightImpact.UserNlpConstraint = @opt.callback.RightImpactConstraints;
    
    
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

