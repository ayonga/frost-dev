function nlp = fanuc_constr_opt_t(nlp, bounds, varargin)
    % add aditional custom constraints
    
    plant = nlp.Plant;
    
    
    % event
    % extract the event function object using the index
    event_obj = plant.EventFuncs.deltafinal;
    % impose the NLP constraints (unilateral constraints)
    event_obj.imposeNLPConstraint(nlp);
    % update the upper bound at the last node to be zero (to ensure equality)
    event_cstr_name = event_obj.ConstrExpr.Name;
    updateConstrProp(nlp,event_cstr_name,'last','ub',0);
    
    % relative degree 2 outputs
    plant.VirtualConstraints.pos.imposeNLPConstraint(nlp, [bounds.pos.kp,bounds.pos.kd], [1,1]);

    %% configuration constraints
        x = plant.States.x;
    dx = plant.States.dx;
    ddx = plant.States.ddx;
   
    
    q_pan = SymFunction(['q_pan_' plant.Name],x(1),{x});
    q_lift= SymFunction(['q_lift_' plant.Name],x(2),{x});
    q_elb = SymFunction(['q_elb_' plant.Name],x(3),{x});
    q_wy = SymFunction(['q_wy_' plant.Name],x(4),{x});
    q_wp = SymFunction(['q_wp_' plant.Name],x(5),{x});
    q_wr = SymFunction(['q_wr_' plant.Name],x(6),{x});
 
    % these are the wrist constraints
%     q_spatula = SymFunction(['q_spatula_' plant.Name],x(end-1),{x});
%     addNodeConstraint(nlp, q_wr, {'x'}, 'first', 0.00386, 0.00386, 'Nonlinear');
%     addNodeConstraint(nlp, q_wr, {'x'}, 'last', pi, pi, 'Nonlinear');
    
    configq = SymFunction(['q_config_' plant.Name],x(1:6),{x});
    q_init = [-0.00523, 0.33250, -0.75715, -0.00764, 0.67811, 0.00386];
    q_final = [0.0045,  0.3103, -1.0157,  0.0141,  0.7948,  3.1363];
    addNodeConstraint(nlp, configq, {'x'}, 1, q_init, q_init, 'Nonlinear');
    addNodeConstraint(nlp, configq, {'x'}, 'last', q_final, q_final, 'Nonlinear');
    
    %%
    spatula_link = plant.Links(getLinkIndices(plant, 'spatula'));
    spatula_frame = spatula_link.Reference;
    spatula = CoordinateFrame(...
        'Name','EndEff',...
        'Reference',spatula_frame,...
        'Offset',[0 0.0298709 0.2022645],...
        'R',[0,0,0]... % z-axis is the normal axis, so no rotation required
        );
    p_spatula = getCartesianPosition(plant,spatula);
   
    
    n_node = nlp.NumNode;
    p_z = p_spatula(3) - 0.5297;
    p_z_func = SymFunction(['endeffclearance_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 1, 0.0, 0.0, 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, n_node, -0.0926, -0.0926, 'Nonlinear');
%     addNodeConstraint(nlp, p_z_func, {'x'}, 'all', 0.0, 0.4, 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, round(n_node/2), 0.1, 0.3, 'Nonlinear');
    
    
    p_x = p_spatula(1);
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 1, 0.8734, 0.8734, 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, round(n_node), 0.7478, 0.7478, 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, 'except-terminal', 0.66, 0.89, 'Nonlinear');
    
    p_y = p_spatula(2);
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 1, 0.0, 0.0, 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, round(n_node), 0.0, 0.0, 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, 'except-terminal', 0.0, 0.08, 'Nonlinear');
    
    %% these are slipping constraints being added

    v_x = jacobian(p_spatula(1), x)*dx ;
    v_y = jacobian(p_spatula(2), x)*dx ;
    v_z = jacobian(p_spatula(3), x)*dx ;
    
    a_x = jacobian(v_x,dx)*ddx + jacobian(v_x,x)*dx;
    a_y = jacobian(v_y,dx)*ddx + jacobian(v_y,x)*dx;
    a_z = jacobian(v_z,dx)*ddx + jacobian(v_z,x)*dx;

    % get orientation of the end effector in terms of euler angles
    orientation = getEulerAngles(plant,spatula);
    g = 9.81; % acceleration due to gravity - a constant
    mu = 0.26; % coefficient of restitution
    
    o_x = orientation(1);
    o_y = orientation(2);
    
    % these are the ee constraints on the end effector
    q_endeffx = SymFunction(['q_endeffx_' plant.Name],o_x,{x});
    q_endeffy = SymFunction(['q_endeffy_' plant.Name],o_y,{x});
%     addNodeConstraint(nlp, q_endeffy, {'x'}, 'all', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, q_endeffx, {'x'}, 'first', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, q_endeffx, {'x'}, 'last', pi, pi, 'Nonlinear'); 
    
    % these are the slipping constraints
    a_slip_y = a_z*sin(o_x) + a_y*cos(o_x) + g*sin(o_x) ...
                - mu* ( - a_y*sin(o_x) + a_z*cos(o_x) + g*cos(o_x));
    a_slip_x = a_z*sin(o_y) + a_x*cos(o_y) + g*sin(o_y) ...
                - mu* (-  a_x*sin(o_y) + a_z*cos(o_y) + g*cos(o_y));
            
            
    a_slip_y_func = SymFunction(['endeffoy_sca_' plant.Name],a_slip_y,{x,dx,ddx});
    addNodeConstraint(nlp, a_slip_y_func, {'x','dx','ddx'}, 1:round(0.8*n_node), -Inf, 0.0, 'Nonlinear');
            
    a_slip_x_func = SymFunction(['endeffox_sca_' plant.Name],a_slip_x,{x,dx,ddx});
    addNodeConstraint(nlp, a_slip_x_func, {'x','dx','ddx'}, 1:round(0.8*n_node), -Inf, 0.0, 'Nonlinear');
    
    
end