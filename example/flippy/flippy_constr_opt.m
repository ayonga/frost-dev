function nlp = flippy_constr_opt(nlp, bounds, varargin)
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
    
    
    
    % relative degree 1 output
    plant.VirtualConstraints.vel.imposeNLPConstraint(nlp, bounds.vel.ep, 0);
    % tau boundary [0,1]
    tau = plant.VirtualConstraints.vel.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','pvel'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','pvel'}, 'last', 1, 1, 'Nonlinear');
    
    % relative degree 2 outputs
    plant.VirtualConstraints.pos.imposeNLPConstraint(nlp, [bounds.pos.kp,bounds.pos.kd], [1,1]);
    % tau boundary [0,1]
    tau = plant.VirtualConstraints.pos.PhaseFuncs{1};
    addNodeConstraint(nlp, tau, {'x','ppos'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, tau, {'x','ppos'}, 'last', 1, 1, 'Nonlinear');
    
    wrist_3_link = plant.Links(getLinkIndices(plant, 'wrist_3_link'));
    wrist_3_frame = wrist_3_link.Reference;
    % wrist_3_joint = obj.Joints(getJointIndices(obj, 'r_leg_akx'));
    EndEff = CoordinateFrame(...
        'Name','EndEff',...
        'Reference',wrist_3_frame,...
        'Offset',[0, 0, 0],...
        'R',[0,0,0]... % z-axis is the normal axis, so no rotation required
        );
    p = getCartesianPosition(plant,EndEff);
    x = plant.States.x;
    p_z = p(3) - 1.0;
    p_z_func = SymFunction(['endeffclearance_sca_' plant.Name],p_z,{x});
    
    n_node = nlp.NumNode;
    addNodeConstraint(nlp, p_z_func, {'x'}, n_node, 0.0, 0.03, 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 1, 0.0, 0.0, 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, round(n_node/2), 0.2, 0.3, 'Nonlinear');
    
    
    p_x = p(1);
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 1, 0.4, 0.5, 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, round(n_node), 0.4, 0.5, 'Nonlinear');
    
    p_y = p(1);
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 1, 0.0, 0.0, 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, round(n_node), 0.0, 0.0, 'Nonlinear');
end