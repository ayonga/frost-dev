function right_stance_constraints(nlp, bounds, varargin)
    
    domain = nlp.Plant;

    % relative degree 2 outputs
    domain.VirtualConstraints.time.imposeNLPConstraint(nlp, [bounds.time.kp, bounds.time.kd], [1,1]);
    
    % tau boundary [0,1]
    T  = SymVariable('t',[2,1]);
    p = {SymVariable(tomatrix(domain.VirtualConstraints.time.PhaseParams(:)))};
    p_name = domain.VirtualConstraints.time.PhaseParamName;
    tau_0 = SymFunction(['tau_0_',domain.Name], T(1) - p{1}(2), [{T},p]);
    tau_F = SymFunction(['tau_F_',domain.Name], T(2) - p{1}(1), [{T},p]);
    addNodeConstraint(nlp, tau_0, [{'T'},p_name], 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau_F, [{'T'},p_name], 'last', 0, 0, 'Nonlinear');
    
    % output boundary 
    y_pos = domain.VirtualConstraints.time;
    y_bound_idx = str_indices({'q1_right','q2_right','q1_left',...
        'q2_left'},y_pos.OutputLabel);
    
    y_bound = y_pos.ActualOutput(y_bound_idx);
    lb = [-2*pi,-2*pi,-2*pi,-2*pi]';
    ub = [2*pi,2*pi,2*pi,2*pi]';
    y_bound_fun = SymFunction(['output_boundary_',domain.Name], y_bound, {domain.States.x});
    addNodeConstraint(nlp, y_bound_fun, {'x'}, 'all', lb, ub,'Linear');
    
    % average velocity
    velocity_desired = 0.75;
    DOF = 7;
    T  = SymVariable('t',[2,1]);
    X0  = SymVariable('x0',[DOF,1]);
    XF  = SymVariable('xF',[DOF,1]);
    avg_vel = (XF(1) - X0(1)) / (T(2) - T(1));
    avg_vel_fun = SymFunction('average_velocity', avg_vel, {T,X0,XF});
    
    avg_vel_cstr = NlpFunction('Name','average_velocity',...
        'Dimension',1,...
        'lb', velocity_desired,...
        'ub', velocity_desired,...
        'Type','Linear',...
        'SymFun',avg_vel_fun,...
        'DepVariables',[nlp.OptVarTable.T(1); nlp.OptVarTable.x(1); nlp.OptVarTable.x(end)]);    
    
    addConstraint(nlp, 'average_velocity', 'last', avg_vel_cstr);
    
    % Swing Foot Clearance
    X  = SymVariable('x',[DOF,1]);
    swingFootHeight = SymFunction('swing_foot_height', nlp.Plant.EventFuncs.leftFootHeight.ConstrExpr, {X});
    addNodeConstraint(nlp, swingFootHeight, {'x'}, floor(nlp.NumNode/2), 0.1, Inf,'Linear');
        
end