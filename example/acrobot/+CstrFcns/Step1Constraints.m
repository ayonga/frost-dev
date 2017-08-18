function nlp = Step1Constraints(nlp, bounds, varargin)
    domain = nlp.Plant;

    %% virtual constraints
    nlp = CstrFcns.ImposeVirtualConstraint(nlp, bounds);
    
    %% initial position
    q0 = bounds.initialPos;
    dq0 = bounds.initialVel;
    
    updateVariableProp(nlp,'x','first','lb',q0,'ub',q0,'x0',q0);
    updateVariableProp(nlp,'dx','first','lb',dq0,'ub',dq0,'x0',dq0);
    
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
    %% initial position
    %     q0 = bounds.restPos;
    %     dq_minus = zeros(6,1);
    %     %     dq0 = bounds.restVel;
    %     %     ddq0 = bounds.restAcc;
    %     robot = nlp.Plant;
    %     D = robot.calcMassMatrix(q0);
    %     Jfoot = Jh_foot_acrobot(q0);
    %     Jimp = jac_push_acrobot(q0);
    %
    %     E = [D -Jfoot';Jfoot, zeros(3,3)];
    %     F = [D*dq_minus + Jimp'*bounds.push_force;
    %         zeros(3,1)];
    %
    %     y = E\F;
    %
    %     dq0 = y(1:6);
    %
    %
    %     updateVariableProp(nlp,'x','first','lb',q0,'ub',q0,'x0',q0);
    %     updateVariableProp(nlp,'dx','first','lb',dq0,'ub',dq0,'x0',dq0);
    %     updateVariableProp(nlp,'ddx','first','lb',ddq0,'ub',ddq0,'x0',ddq0);
    
    %     updateVariableProp(nlp,'x','last','lb',q0,'ub',q0,'x0',q0);
    %     updateVariableProp(nlp,'dx','last','lb',dq0,'ub',dq0,'x0',dq0);
    %     updateVariableProp(nlp,'ddx','last','lb',ddq0,'ub',ddq0,'x0',ddq0);
    
    %     D = nlp.Plant.Mmat;
    %     q = nlp.Plant.States.x;
    %     dq = nlp.Plant.States.dx;
    %
    %     f_push = CoordinateFrame('Name','push',...
    %         'Reference',nlp.Plant.Joints(end),...
    %         'Offset',[0,0,0.3],...
    %         'R',[0,0,0]);
    %
    %     %     p_push_sym = getCartesianPosition(robot,f_push);
    %     J_push_sym = getSpatialJacobian(nlp.Plant,f_push);
    %     J = J_push_sym([1,3],:);
    %
    %     F = SymVariable('f',[2,1]);
    %
    %     nlp.addVariable('fg','first','Name','fg','Dimension',3,...
    %         'lb',[-inf,0,-inf],'ub',[inf,inf,inf],'x0',[0,0,0]);
    %     Fg = SymVariable('fg',[3,1]);
    %     Jg = nlp.Plant.Gmap.ConstraintWrench.ffoot;
    %     constr = D*dq - J.'*F + Jg*Fg;
    %     constr_fun = SymFunction(['impact_',nlp.Plant.Name],constr,{q,dq,Fg},{F});
    %     addNodeConstraint(nlp,constr_fun,{'x','dx','fg'},'first',0,0,'Nonlinear',bounds.push_force);
end