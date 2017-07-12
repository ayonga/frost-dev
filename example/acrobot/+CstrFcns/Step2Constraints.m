function nlp = Step2Constraints(nlp, bounds, varargin)
    
    %% virtual constraints
    nlp = CstrFcns.ImposeVirtualConstraint(nlp, bounds);


    %% target position
    %     q0 = bounds.restPos;
    %     dq0 = bounds.restVel;
    %     ddq0 = bounds.restAcc;
    %
    %     updateVariableProp(nlp,'x','first','lb',q0,'ub',q0,'x0',q0);
    %     updateVariableProp(nlp,'dx','first','lb',dq0,'ub',dq0,'x0',dq0);
    %     updateVariableProp(nlp,'ddx','first','lb',ddq0,'ub',ddq0,'x0',ddq0);
    %
    %     updateVariableProp(nlp,'x','last','lb',q0,'ub',q0,'x0',q0);
    %     updateVariableProp(nlp,'dx','last','lb',dq0,'ub',dq0,'x0',dq0);
    %     updateVariableProp(nlp,'ddx','last','lb',ddq0,'ub',ddq0,'x0',ddq0);
end