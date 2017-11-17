function average_velocity(nlp, bounds)
    % constraints for impact velocities
    
    domain = nlp.Plant;
    x = domain.States.x;
    
    % average step velocity
    v_lb = bounds.constrBounds.averageVelocity.lb;
    v_ub = bounds.constrBounds.averageVelocity.ub;
    x0 = x;
    xf = SymVariable('xf',size(x));
    T  = SymVariable('t',[2,1]);
    v_avg = [(xf(1)-x0(1))./(T(2)-T(1))
        (xf(2)-x0(2))./(T(2)-T(1))];
    v_avg_fun = SymFunction(['avgStepVelocity_',domain.Name],v_avg,{T, x0, xf});
    x0_var = nlp.OptVarTable.x(1);
    xf_var = nlp.OptVarTable.x(end);
    t_var  = nlp.OptVarTable.T(1);
    v_avg_cstr = NlpFunction('Name',v_avg_fun.Name,...
        'Dimension',2,'lb',v_lb, 'ub',v_ub,'Type','Nonlinear',...
        'SymFun',v_avg_fun,'DepVariables',[t_var;x0_var;xf_var]);
    addConstraint(nlp, 'avgStepVelocity', 'first', v_avg_cstr);
    
end

