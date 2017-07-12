function nlp = StepConstraints(nlp, bounds, varargin)
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
    constr_fun = SymFunction(['pcom_',domain.Name],pcom([1,3]),{domain.States.x});
    lb = [bounds.xcom.lb;bounds.zcom.lb];
    ub = [bounds.xcom.ub;bounds.zcom.ub];
    addNodeConstraint(nlp,constr_fun,{'x'},'first', lb, ub,'Nonlinear');
end