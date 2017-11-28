function [system] = LoadTransSystem(model, load_path)
    % Load the hybrid system model 
    
    if nargin < 2
        load_path = [];
    end
    
    
    rightStance1 = sys.domains.RightStance(model, load_path);
    rightStance1.UserNlpConstraint = @trans_opt.callback.RightStance1Constraints;
    leftStance1 = sys.domains.LeftStance(model, load_path);
    leftStance1.UserNlpConstraint = @trans_opt.callback.LeftStance1Constraints;
    
    rightStance2 = copy(rightStance1);
    rightStance2.setName('RightStance2');
    rightStance2.UserNlpConstraint = @trans_opt.callback.RightStance2Constraints;
    leftStance2 = copy(leftStance1);
    leftStance2.setName('LeftStance2');
    leftStance2.UserNlpConstraint = @trans_opt.callback.LeftStance2Constraints;
    
    leftImpact1 = RigidImpact('LeftImpact', leftStance1, 'leftFootHeight'); % To leftStance
    leftImpact1.addImpactConstraint(struct2array(leftStance1.HolonomicConstraints), load_path);
    leftImpact1.UserNlpConstraint = @trans_opt.callback.LeftImpactConstraints;
    
    rightImpact1 = RigidImpact('RightImpact', rightStance1, 'rightFootHeight'); % To rightStance
    rightImpact1.addImpactConstraint(struct2array(rightStance1.HolonomicConstraints), load_path);
    rightImpact1.UserNlpConstraint = @trans_opt.callback.RightImpactConstraints;
    
    leftImpact2 = copy(leftImpact1);
    %     leftImpact2 = RigidImpact('LeftImpact2', leftStance2, 'leftFootHeight'); % To leftStance
    %     leftImpact2.addImpactConstraint(struct2array(leftStance2.HolonomicConstraints), load_path);
    %     leftImpact2.UserNlpConstraint = @trans_opt.callback.LeftImpact2Constraints;
    
    %     rightImpact2 = RigidImpact('RightImpact2', rightStance2, 'rightFootHeight'); % To rightStance
    %     rightImpact2.addImpactConstraint(struct2array(rightStance2.HolonomicConstraints), load_path);
    %     rightImpact2 = copy(rightImpact1);
    %     rightImpact2.setName('RightImpact2');
    %     rightImpact2.UserNlpConstraint = @trans_opt.callback.RightImpact2Constraints;
    %
    
    io_control  = IOFeedback('IO');

    system = HybridSystem('atrias');
    system = addVertex(system, 'RightStance1', 'Domain', rightStance1, ...
        'Control', io_control);
    system = addVertex(system, 'LeftStance1', 'Domain', leftStance1, ...
        'Control', io_control);
    system = addVertex(system, 'RightStance2', 'Domain', rightStance2, ...
        'Control', io_control);
    system = addVertex(system, 'LeftStance2', 'Domain', leftStance2, ...
        'Control', io_control);

    srcs = {'RightStance1'
        'LeftStance1'
        'RightStance2'};

    tars = {'LeftStance1'
        'RightStance2'
        'LeftStance2'};

    system = addEdge(system, srcs, tars);
    system = setEdgeProperties(system, srcs, tars, ...
        'Guard', {leftImpact1, rightImpact1, leftImpact2});
    
    
end

