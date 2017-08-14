function [robot, sys] = LoadModel()
    
    robot = Model.acrobot();
    robot.configureDynamics();
    
    [frame, fric_coef, geom] = Model.GetContactFrame(robot);
    robot = addContact(robot,frame,fric_coef,geom);
    
    %% relative degree two outputs:
    ya_2 = robot.States.x(4:end);
    t = SymVariable('t');
    p = SymVariable('p',[2,1]);
    tau = (t-p(2))/(p(1)-p(2));
    y2 = VirtualConstraint(robot,ya_2,'joints','DesiredType','Bezier','PolyDegree',5,...
        'RelativeDegree',2,'PhaseType','TimeBased',...
        'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true);
    
    robot = addVirtualConstraint(robot,y2);
    
    robot.UserNlpConstraint = @CstrFcns.StepConstraints;
    %% create a pseudo hybrid system model with three continuous domain
    io_control  = IOFeedback('IO');
    
    step1 = copy(robot);
    step2 = copy(robot);
%     step3 = copy(robot);

    sys = HybridSystem('AcrobotThreeStep');
    sys = addVertex(sys, 'step1', 'Domain', step1, ...
        'Control', io_control);
    sys = addVertex(sys, 'step2', 'Domain', step2, ...
        'Control', io_control);
%     sys = addVertex(sys, 'step3', 'Domain', step3, ...
%         'Control', io_control);
    
    sw1 = RigidImpact('sw1',robot);
%     sw2 = RigidImpact('sw2',robot);
    
    sys = addEdge(sys, 'step1','step2', 'Guard',sw1);
%     sys = addEdge(sys, 'step2','step3', 'Guard',sw2);
    
    
    step1.UserNlpConstraint = @CstrFcns.Step1Constraints;
    step2.UserNlpConstraint = @CstrFcns.Step2Constraints;
%     step3.UserNlpConstraint = @CstrFcns.Step3Constraints;
end