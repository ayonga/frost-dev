function nlp = StaticStepConstraints(nlp, bounds, varargin)
    domain = nlp.Plant;
    
    %% virtual constraints
    nlp = CstrFcns.ImposeVirtualConstraint(nlp, bounds);


    %% target position
    q0 = bounds.restPos;
    dq0 = bounds.restVel;
    ddq0 = bounds.restAcc;

    %     updateVariableProp(nlp,'x','last','lb',q0,'ub',q0,'x0',q0);
    updateVariableProp(nlp,'dx','all','lb',dq0,'ub',dq0,'x0',dq0);
    updateVariableProp(nlp,'ddx','all','lb',ddq0,'ub',ddq0,'x0',ddq0);
    
    
    %% pcom position
    pcom = domain.getComPosition();
    %     constr_fun = SymFunction(['pcom_',domain.Name],pcom([1,3]),{domain.States.x});
    %     lb = [bounds.xcom.lb;bounds.zcom.lb];
    %     ub = [bounds.xcom.ub;bounds.zcom.ub];
    %     addNodeConstraint(nlp,constr_fun,{'x'},'all', lb, ub,'Nonlinear');
    
    rcom = sqrt((pcom(1)+0.15).^2 + pcom(3).^2);
    constr_fun = SymFunction(['rcom_',domain.Name],rcom,{domain.States.x});
    lb = bounds.rcom.lb;
    ub = bounds.rcom.ub;
    addNodeConstraint(nlp,constr_fun,{'x'},'all', lb, ub,'Nonlinear');
    
    theta = atan2(pcom(3),(pcom(1)+0.15));
    constr_fun = SymFunction(['theta_com_',domain.Name],theta,{domain.States.x});
    lb = bounds.thetacom.lb;
    ub = bounds.thetacom.ub;
    addNodeConstraint(nlp,constr_fun,{'x'},'all', lb, ub,'Nonlinear');
    %% torso
    
    torso = CoordinateFrame('Name','torso',...
        'Reference',nlp.Plant.Joints(end),...
        'Offset',[0,0,0.3],...
        'R',[0,0,0]);
    rpy = getEulerAngles(domain, torso);
    constr_fun = SymFunction(['torso_',domain.Name],rpy(2),{domain.States.x});
    lb = bounds.torso.lb;
    ub = bounds.torso.ub;
    addNodeConstraint(nlp,constr_fun,{'x'},'all', lb, ub,'Linear');
end