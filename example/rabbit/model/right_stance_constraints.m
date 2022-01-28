function right_stance_constraints(nlp, bounds, varargin)
    
    domain = nlp.Plant;

    vc = domain.VirtualConstraints.Outputs;
    
    vc.imposeNLPConstraint(nlp, [100,20], [1,1]);
    
    % tau boundary [0,1]
    T_name = nlp.OptVarTable.T(1).Name;
    T  = SymVariable(lower(T_name),[nlp.OptVarTable.T(1).Dimension,1]);
    p_name = nlp.OptVarTable.pOutputs(1).Name;
    p  = SymVariable(lower(p_name),[nlp.OptVarTable.pOutputs(1).Dimension,1]);
    tau = SymFunction(['tau_',domain.Name], T- p, {T,p});
    addNodeConstraint(nlp, 'first', tau, {T_name,p_name}, 0, 0);
    
    % average velocity
    velocity_desired = 0.75;
    DOF = domain.Dimension;
    T  = SymVariable('t',[2,1]);
    X0  = SymVariable('x0',[DOF,1]);
    XF  = SymVariable('xF',[DOF,1]);
    avg_vel = (XF(1) - X0(1)) / (T(2) - T(1));
    avg_vel_fun = SymFunction('average_velocity', avg_vel, {T,X0,XF});
    dep_vars = [nlp.OptVarTable.T(1); nlp.OptVarTable.x(1); nlp.OptVarTable.x(end)];
    avg_vel_cstr = NlpFunction(avg_vel_fun, dep_vars, ...
        'lb', velocity_desired,...
        'ub', velocity_desired);
    
    addConstraint(nlp, 'last', avg_vel_cstr);
    
    % Swing Foot Clearance
    addNodeConstraint(nlp, floor(nlp.NumNode/2),nlp.Plant.EventFuncs.nsf_height.ConstrExpr, {'x'}, 0.1, Inf);
        
end