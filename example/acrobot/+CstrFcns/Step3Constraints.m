function nlp = Step3Constraints(nlp, bounds, varargin)
    domain = nlp.Plant;
    
    %% virtual constraints
    nlp = CstrFcns.ImposeVirtualConstraint(nlp, bounds);


    %% target position
    q0 = bounds.restPos;
    dq0 = bounds.restVel;
    ddq0 = bounds.restAcc;
    
    %     updateVariableProp(nlp,'x','first','lb',q0,'ub',q0,'x0',q0);
    %     updateVariableProp(nlp,'dx','first','lb',dq0,'ub',dq0,'x0',dq0);
    %     updateVariableProp(nlp,'ddx','first','lb',ddq0,'ub',ddq0,'x0',ddq0);

    updateVariableProp(nlp,'x','last','lb',q0,'ub',q0,'x0',q0);
    updateVariableProp(nlp,'dx','last','lb',dq0,'ub',dq0,'x0',dq0);
    updateVariableProp(nlp,'ddx','last','lb',ddq0,'ub',ddq0,'x0',ddq0);
    
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