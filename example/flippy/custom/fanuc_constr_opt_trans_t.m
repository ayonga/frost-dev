function nlp = fanuc_constr_opt_trans_t(nlp, bounds, varargin)
    
%%  Specify the starting and the ending position
    p_end = [0.4, 0.7, 0.25];
    p_start = [-0.2, 0.7, 0.25];
%%  Specify the starting and the ending orienation
    o_end = [0,0,pi/2];
    o_start   = [0,0,pi/2];

%%
    % add aditional custom constraints
    
    plant = nlp.Plant;
    
        
    % relative degree 2 outputs
    % imposing this constraint is very important for getting the apos
    % matrix correct
    plant.VirtualConstraints.pos.imposeNLPConstraint(nlp, [bounds.pos.kp,bounds.pos.kd], [1,1]);

    %% configuration constraints
    x = plant.States.x;
    dx = plant.States.dx;
    ddx = plant.States.ddx;

%     addNodeConstraint(nlp, configq, {'x'}, 1, q_init_L, q_init_U, 'Nonlinear');
%     addNodeConstraint(nlp, configq, {'x'}, 'last', q_final_L, q_final_U, 'Nonlinear');
    
    %%
    spatula_link = plant.Links(getLinkIndices(plant, 'link_6'));

    spatula_tool_frame = spatula_link.Reference;

    spatula = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',[-0.014 0.0 0.208],... 
        'R',[0,-2 * pi/3,-23*pi/180]... 
        );
    
    spatula_ledge = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',[-0.014 0.04 0.208],... 
        'R',[0,-2 * pi/3,-23*pi/180]... 
        );
    
    spatula_redge = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',[-0.014 -0.04 0.208],... 
        'R',[0,-2 * pi/3,-23*pi/180]... 
        );
    
    p_spatula = getCartesianPosition(plant,spatula);
    p_lspatula = getCartesianPosition(plant,spatula_ledge);
    p_rspatula = getCartesianPosition(plant,spatula_redge);
   
%% This is x position of end effector
    n_node = nlp.NumNode;
    p_x = p_spatula(1);
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 'first', p_start(1), p_start(1), 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, 'last', p_end(1), p_end(1), 'Nonlinear');
%     addNodeConstraint(nlp, p_x_func, {'x'}, round(0.4*n_node):round(0.75*n_node), -0.0, 0.7, 'Nonlinear');
%% This is y position of end effector
    p_y = p_spatula(2);
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 'first', p_start(2), p_start(2), 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, 'last', p_end(2), p_end(2), 'Nonlinear');
% %     addNodeConstraint(nlp, p_y_func, {'x'}, 'except-terminal', 0.0, 0.2, 'Nonlinear');
    
%% This is z position of end effector    
    basez_offset_wrt_origin =  0.3381; % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 'first', p_start(3), p_start(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'last', p_end(3), p_end(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'except-terminal', 0.10, 0.4, 'Nonlinear');
%     addNodeConstraint(nlp, p_z_func, {'x'}, round(n_node/2), 0.1, 0.3, 'Nonlinear');
%     
    %% these are slipping constraints being added

    v_x = jacobian(p_spatula(1), x)*dx ;
    v_y = jacobian(p_spatula(2), x)*dx ;
    v_z = jacobian(p_spatula(3), x)*dx ;
    
    a_x = jacobian(v_x,dx)*ddx + jacobian(v_x,x)*dx;
    a_y = jacobian(v_y,dx)*ddx + jacobian(v_y,x)*dx;
    a_z = jacobian(v_z,dx)*ddx + jacobian(v_z,x)*dx;    
    
%     velocity functions
    vx_func = SymFunction(['endeffvx_sca_' plant.Name],v_x,{x,dx});
    vy_func = SymFunction(['endeffvy_sca_' plant.Name],v_y,{x,dx});
    vz_func = SymFunction(['endeffvz_sca_' plant.Name],v_z,{x,dx});

    addNodeConstraint(nlp, vx_func, {'x','dx'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'first', 0, 0, 'Nonlinear');
    
    addNodeConstraint(nlp, vx_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');

    % acceleration functions
%     ax_func = SymFunction(['endeffax_sca_' plant.Name],a_x,{x,dx,ddx});
%     ay_func = SymFunction(['endeffay_sca_' plant.Name],a_y,{x,dx,ddx});
%     az_func = SymFunction(['endeffaz_sca_' plant.Name],a_z,{x,dx,ddx});

%     addNodeConstraint(nlp, ax_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, ay_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, az_func, {'x','dx','ddx'}, 'first', -Inf, Inf, 'Nonlinear');
    

    g = -9.81; % acceleration due to gravity - a constant
    mu = 0.16; % coefficient of restitution
    
    R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
            
    normal_vector_spatula = R_vec_spatula([3,6,9]);
    
    dot_product_normal_to_acceleration = normal_vector_spatula ...
                                         * [a_x;
                                            a_y;
                                            a_z-g] / sqrt(a_x^2 + a_y^2 + (a_z-g)^2);

    slipping_func = SymFunction(['slipping_sca_' plant.Name],dot_product_normal_to_acceleration,{x,dx,ddx});
    addNodeConstraint(nlp, slipping_func, {'x','dx','ddx'}, 1:n_node, cos(mu), 1, 'Nonlinear');
    
    
%     normal_vector = SymFunction(['normal_vector_' plant.Name],normal_vector_spatula,{x});
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'all', [0,0,0.2], [1,1,1], 'Nonlinear');
    
    
    % get orientation of the end effector in terms of euler angles
    orientation = getRelativeEulerAngles(plant,spatula);
    o_x = orientation(1);
    o_y = orientation(2);
    o_z = orientation(3);    
              
    
    % these are the ee constraints on the end effector
    o_endeffx = SymFunction(['o_endeffx_' plant.Name],o_x,{x});
    o_endeffy = SymFunction(['o_endeffy_' plant.Name],o_y,{x});
    o_endeffz = SymFunction(['o_endeffz_' plant.Name],o_z,{x});
        
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'first', o_start(1), o_start(1), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'last',  o_end(1), o_end(1), 'Nonlinear'); 
%     addNodeConstraint(nlp, o_endeffx, {'x'}, 'except-terminal',  -pi + 0.05, 0, 'Nonlinear');

%     addNodeConstraint(nlp, o_endeffy, {'x'}, 'all', -0.2, 0.2, 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'first', o_start(2), o_start(2), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'last',   o_end(2), o_end(2), 'Nonlinear');

    addNodeConstraint(nlp, o_endeffz, {'x'}, 'first', o_start(3), o_start(3), 'Nonlinear'); 
    addNodeConstraint(nlp, o_endeffz, {'x'}, 'last', o_end(3), o_end(3), 'Nonlinear'); 
%     addNodeConstraint(nlp, o_endeffy, {'x'}, 'all', 0, 0, 'Nonlinear'); 
    
%% Left spatula edge acceleration constraints
    lv_x = jacobian(p_lspatula(1), x)*dx ;
    lv_y = jacobian(p_lspatula(2), x)*dx ;
    lv_z = jacobian(p_lspatula(3), x)*dx ;
    
    la_x = jacobian(lv_x,dx)*ddx + jacobian(lv_x,x)*dx;
    la_y = jacobian(lv_y,dx)*ddx + jacobian(lv_y,x)*dx;
    la_z = jacobian(lv_z,dx)*ddx + jacobian(lv_z,x)*dx;    
    
    dot_product_normal_to_lacceleration = normal_vector_spatula ...
                                         * [la_x;
                                            la_y;
                                            la_z-g] / sqrt(la_x^2 + la_y^2 + (la_z-g)^2);

    lslipping_func = SymFunction(['lslipping_sca_' plant.Name],dot_product_normal_to_lacceleration,{x,dx,ddx});
    addNodeConstraint(nlp, lslipping_func, {'x','dx','ddx'}, 1:n_node, cos(mu), 1, 'Nonlinear');
    
%% Right spatula edge acceleration constraints
    rv_x = jacobian(p_rspatula(1), x)*dx ;
    rv_y = jacobian(p_rspatula(2), x)*dx ;
    rv_z = jacobian(p_rspatula(3), x)*dx ;
    
    ra_x = jacobian(rv_x,dx)*ddx + jacobian(rv_x,x)*dx;
    ra_y = jacobian(rv_y,dx)*ddx + jacobian(rv_y,x)*dx;
    ra_z = jacobian(rv_z,dx)*ddx + jacobian(rv_z,x)*dx;
    
    dot_product_normal_to_racceleration = normal_vector_spatula ...
                                         * [ra_x;
                                            ra_y;
                                            ra_z-g] / sqrt(ra_x^2 + ra_y^2 + (ra_z-g)^2);

    rslipping_func = SymFunction(['rslipping_sca_' plant.Name],dot_product_normal_to_racceleration,{x,dx,ddx});
    addNodeConstraint(nlp, rslipping_func, {'x','dx','ddx'}, 1:n_node, cos(mu), 1, 'Nonlinear');
    
end