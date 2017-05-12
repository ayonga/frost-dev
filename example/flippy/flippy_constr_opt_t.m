function nlp = flippy_constr_opt_t(nlp, bounds, varargin)
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
%     tau = plant.VirtualConstraints.vel.PhaseFuncs{1};
%     addNodeConstraint(nlp, tau, {'x','pvel'}, 'first', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, tau, {'x','pvel'}, 'last', 1, 1, 'Nonlinear');
    
    % relative degree 2 outputs
    plant.VirtualConstraints.pos.imposeNLPConstraint(nlp, [bounds.pos.kp,bounds.pos.kd], [1,1]);
    % tau boundary [0,1]
    tau = plant.VirtualConstraints.pos.PhaseFuncs{1};
    t = SymVariable('t');
    k = SymVariable('k');
    T  = SymVariable('t',[2,1]);
    nNode = SymVariable('nNode');
    tsubs = T(1) + ((k-1)./(nNode-1)).*(T(2)-T(1));
    tau_new = subs(tau,t,tsubs);
    if ~isempty(plant.VirtualConstraints.pos.PhaseParams)
        p = {SymVariable(tomatrix(plant.VirtualConstraints.pos.PhaseParams(:)))};
        p_name = plant.VirtualConstraints.pos.PhaseParamName;
    else
        p = {};
        p_name = {};
    end
    
    tau_new_fun = SymFunction(['tau_bound_',plant.Name], tau_new, [{T},p],{k,nNode});
    addNodeConstraint(nlp, tau_new_fun, [{'T'},p_name], 'first', 0, 0, 'Nonlinear',{1,nlp.NumNode});
    addNodeConstraint(nlp, tau_new_fun, [{'T'},p_name], 'last', 1, 1, 'Nonlinear',{nlp.NumNode,nlp.NumNode});
    
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
    dx = plant.States.dx;
    ddx = plant.States.ddx;
    
    
    n_node = nlp.NumNode;
    p_z = p(3) - 1.0;
    p_z_func = SymFunction(['endeffclearance_sca_' plant.Name],p_z,{x});
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
    
    % get acceleration along x, y and z directions of end effector
    v_x = jacobian(p_x, x)*dx ;
    v_y = jacobian(p_y, x)*dx ;
    v_z = jacobian(p_z, x)*dx ;
    
    a_x = jacobian(v_x,dx)*ddx + jacobian(v_x,x)*dx;
    a_y = jacobian(v_y,dx)*ddx + jacobian(v_y,x)*dx;
    a_z = jacobian(v_z,dx)*ddx + jacobian(v_z,x)*dx;

    % get orientation of the end effector in terms of euler angles
    orientation = getEulerAngles(plant,EndEff);
    g = 9.81; % acceleration due to gravity - a constant
    mu = 0.26; % coefficient of restitution
    
    o_x = orientation(1);
    o_y = orientation(2);
    
    % these are the slipping constraints
    a_slip_y = a_z*sin(o_x)-a_y*cos(o_x)+g*sin(o_x) ...
                - mu* (a_y*sin(o_x) + a_z*cos(o_x) + g*cos(o_x));
    a_slip_x = a_z*sin(o_y)-a_x*cos(o_y)+g*sin(o_y) ...
                - mu* (a_x*sin(o_y) + a_z*cos(o_y) + g*cos(o_y));
            
    a_slip_y_func = SymFunction(['endeffoy_sca_' plant.Name],a_slip_y,{x,dx,ddx});
%     addNodeConstraint(nlp, a_slip_y_func, {'x','dx','ddx'}, 'all', -1000, 0.0, 'Nonlinear');
            
    a_slip_x_func = SymFunction(['endeffox_sca_' plant.Name],a_slip_x,{x,dx,ddx});
%     addNodeConstraint(nlp, a_slip_x_func, {'x','dx','ddx'}, 'all', -1000, 0.0, 'Nonlinear');
    
    
end