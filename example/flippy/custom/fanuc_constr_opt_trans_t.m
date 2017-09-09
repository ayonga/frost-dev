function nlp = fanuc_constr_opt_trans_t(nlp, bounds, varargin)
    
%%  Specify the starting and the ending position
    p_start = [0.75, -0.2, 0.13];
    p_end = [0.2, 0.55, 0.25];
%%  Specify the starting and the ending orienation
    o_start = [0,0,0];
    o_end   = [0,0,atan2(p_end(2),p_end(1))];

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
   
    
%     q_pan = SymFunction(['q_pan_' plant.Name],x(1),{x});
%     q_lift= SymFunction(['q_lift_' plant.Name],x(2),{x});
%     q_elb = SymFunction(['q_elb_' plant.Name],x(3),{x});
%     q_wy = SymFunction(['q_wy_' plant.Name],x(4),{x});
%     q_wp = SymFunction(['q_wp_' plant.Name],x(5),{x});
%     q_wr = SymFunction(['q_wr_' plant.Name],x(6),{x});
 
    % these are the wrist constraints
%     q_spatula = SymFunction(['q_spatula_' plant.Name],x(end-1),{x});
%     addNodeConstraint(nlp, q_wr, {'x'}, 'first', 0.00386, 0.00386, 'Nonlinear');
%     addNodeConstraint(nlp, q_wr, {'x'}, 'last', pi, pi, 'Nonlinear');
    

%     addNodeConstraint(nlp, configq, {'x'}, 1, q_init_L, q_init_U, 'Nonlinear');
%     addNodeConstraint(nlp, configq, {'x'}, 'last', q_final_L, q_final_U, 'Nonlinear');
    
    %%
    spatula_link = plant.Links(getLinkIndices(plant, 'link_6'));

    spatula_tool_frame = spatula_link.Reference;

    spatula = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',[0.01716 0.0 0.204],...
        'R',[0,-2 * pi/3,-23*pi/180]... 
        );
    
%     spatula_point_negative_y = CoordinateFrame(...
%                                 'Name','SpatulaTool',...
%                                 'Reference',spatula_tool_frame,...
%                                 'Offset',[0.01716, -0.25, 0.204],...
%                                 'R',[0,0,0]... 
%                                 );
%                             
%     spatula_point_positive_y = CoordinateFrame(...
%                                 'Name','SpatulaTool',...
%                                 'Reference',spatula_tool_frame,...
%                                 'Offset',[0.01716, 0.25, 0.204],...
%                                 'R',[0,0,0]...
%                                 );
%                             
%     spatula_point_positive_x = CoordinateFrame(...
%                                 'Name','SpatulaTool',...
%                                 'Reference',spatula_tool_frame,...
%                                 'Offset',[0.01716+0.5*cos(pi/6), 0, 0.204+0.5*sin(pi/6)],...
%                                 'R',[0,0,0]... 
%                                 );
                            
    p_spatula = getCartesianPosition(plant,spatula);
%     p_spatula_point_negative_y = getCartesianPosition(plant,spatula_point_negative_y);
%     p_spatula_point_positive_y = getCartesianPosition(plant,spatula_point_positive_y);
%     p_spatula_point_positive_x = getCartesianPosition(plant,spatula_point_positive_x);
   
%% This is x position of end effector
    p_x = p_spatula(1);
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 'first', p_start(1), p_start(1), 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, 'last', p_end(1), p_end(1), 'Nonlinear');
%     addNodeConstraint(nlp, p_x_func, {'x'}, 'except-terminal', 0.734, 0.734, 'Nonlinear');
%% This is y position of end effector
    p_y = p_spatula(2);
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 'first', p_start(2), p_start(2), 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, 'last', p_end(2), p_end(2), 'Nonlinear');
% %     addNodeConstraint(nlp, p_y_func, {'x'}, 'except-terminal', 0.0, 0.2, 'Nonlinear');
    
%% This is z position of end effector    
    n_node = nlp.NumNode;
    basez_offset_wrt_origin =  0.3381; % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 'first', p_start(3), p_start(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'last', p_end(3), p_end(3), 'Nonlinear');
%     addNodeConstraint(nlp, p_z_func, {'x'}, 'all', 0.11, 0.4, 'Nonlinear');
%     addNodeConstraint(nlp, p_z_func, {'x'}, round(n_node/2), 0.1, 0.3, 'Nonlinear');
%     
    %% these are slipping constraints being added

    v_x = jacobian(p_spatula(1), x)*dx ;
    v_y = jacobian(p_spatula(2), x)*dx ;
    v_z = jacobian(p_spatula(3), x)*dx ;
    
    a_x = jacobian(v_x,dx)*ddx + jacobian(v_x,x)*dx;
    a_y = jacobian(v_y,dx)*ddx + jacobian(v_y,x)*dx;
    a_z = jacobian(v_z,dx)*ddx + jacobian(v_z,x)*dx;
    
    % acceleration functions
%     ax_func = SymFunction(['endeffax_sca_' plant.Name],a_x,{x,dx,ddx});
%     ay_func = SymFunction(['endeffay_sca_' plant.Name],a_y,{x,dx,ddx});
%     az_func = SymFunction(['endeffaz_sca_' plant.Name],a_z,{x,dx,ddx});

%     addNodeConstraint(nlp, ax_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, ay_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, az_func, {'x','dx','ddx'}, 'first', -Inf, Inf, 'Nonlinear');
    

    g = -9.81; % acceleration due to gravity - a constant
    mu = 0.36; % coefficient of restitution
    
    R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
            
    normal_vector_spatula = R_vec_spatula([3,6,9]);
    
    dot_product_normal_to_acceleration = normal_vector_spatula ...
                                         * [a_x;
                                            a_y;
                                            a_z-g] / sqrt(a_x^2 + a_y^2 + (a_z-g)^2);

    slipping_func = SymFunction(['slipping_sca_' plant.Name],dot_product_normal_to_acceleration,{x,dx,ddx});
    addNodeConstraint(nlp, slipping_func, {'x','dx','ddx'}, 1:n_node, cos(mu), 1, 'Nonlinear');
    
    
%     normalvectortospatula_func_x = SymFunction(['spatulanormalx_vector_' plant.Name],normal_vector_to_spatula_x,{x});
%     normalvectortospatula_func_y = SymFunction(['spatulanormaly_vector_' plant.Name],normal_vector_to_spatula_y,{x});
%     normalvectortospatula_func_z = SymFunction(['spatulanormalz_vector_' plant.Name],normal_vector_to_spatula_z,{x});
%     
%     addNodeConstraint(nlp, normalvectortospatula_func_x, {'x'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, normalvectortospatula_func_y, {'x'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, normalvectortospatula_func_z, {'x'}, 'first', -Inf, Inf , 'Nonlinear');
    
%     f_cone = getFrictionConeCosine(plant,spatula,[0,0,1]);
    
    % get orientation of the end effector in terms of euler angles
    orientation = getRelativeEulerAngles(plant,spatula);
    o_x = orientation(1);
    o_y = orientation(2);
    o_z = orientation(3);    
              
    
    % these are the ee constraints on the end effector
    o_endeffx = SymFunction(['o_endeffx_' plant.Name],o_x,{x});
    o_endeffy = SymFunction(['o_endeffy_' plant.Name],o_y,{x});
    o_endeffz = SymFunction(['o_endeffz_' plant.Name],o_z,{x});
    
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'all', -pi, pi , 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'all', -pi/2, pi/2, 'Nonlinear');
    addNodeConstraint(nlp, o_endeffz, {'x'}, 'all', -pi/2, pi/2, 'Nonlinear');
    
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'first', o_start(1), o_start(1), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'last',  o_end(1), o_end(1), 'Nonlinear'); 
%     addNodeConstraint(nlp, o_endeffx, {'x'}, 'except-terminal',  -pi + 0.05, 0, 'Nonlinear');

%     addNodeConstraint(nlp, o_endeffy, {'x'}, 'all', -0.2, 0.2, 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'first', o_start(2), o_start(2), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'last',   o_end(2), o_end(2), 'Nonlinear');

    addNodeConstraint(nlp, o_endeffz, {'x'}, 'first', o_start(3), o_start(3), 'Nonlinear'); 
    addNodeConstraint(nlp, o_endeffz, {'x'}, 'last', o_end(3), o_end(3), 'Nonlinear'); 
%     addNodeConstraint(nlp, o_endeffy, {'x'}, 'all', 0, 0, 'Nonlinear'); 
    
% %     % these are the slipping constraints
%     a_slip_positive_y = - a_z*sin(o_x) - a_y*cos(o_x) - g*sin(o_x) ...
%                 - mu* ( - a_y*sin(o_x) + a_z*cos(o_x) + g*cos(o_x) );
%     a_slip_negative_y = a_z*sin(o_x) + a_y*cos(o_x) + g*sin(o_x) ...
%                 - mu* ( - a_y*sin(o_x) + a_z*cos(o_x) + g*cos(o_x) );
%     a_slip_positive_x = a_z*sin(o_y) - a_x*cos(o_y) + g*sin(o_y) ...
%                 - mu* (  a_x*sin(o_y) + a_z*cos(o_y) + g*cos(o_y));
%     a_slip_negative_x = - a_z*sin(o_y) + a_x*cos(o_y) - g*sin(o_y) ...
%                 - mu* (  a_x*sin(o_y) + a_z*cos(o_y) + g*cos(o_y));
   
            
% % slipping conditions for both negative rotation and positive rotation can be handled if both the
% % constraints below are added
%     a_slip_positivey_func = SymFunction(['endeffslipoy_positive_sca_' plant.Name],a_slip_positive_y,{x,dx,ddx});
%     addNodeConstraint(nlp, a_slip_positivey_func, {'x','dx','ddx'}, 1:n_node, -Inf, 0.0, 'Nonlinear');
%     a_slip_negativey_func = SymFunction(['endeffslipoy_negative_sca_' plant.Name],a_slip_negative_y,{x,dx,ddx});
%     addNodeConstraint(nlp, a_slip_negativey_func, {'x','dx','ddx'}, 1:n_node, -Inf, 0.0, 'Nonlinear');
%             
%     
%     a_slip_positivex_func = SymFunction(['endeffslipox_positive_sca_' plant.Name],a_slip_positive_x,{x,dx,ddx});
%     addNodeConstraint(nlp, a_slip_positivex_func, {'x','dx','ddx'}, 1:n_node, -Inf, 0.0, 'Nonlinear');
%     a_slip_negativex_func = SymFunction(['endeffslipox_negative_sca_' plant.Name],a_slip_negative_x,{x,dx,ddx});
%     addNodeConstraint(nlp, a_slip_negativex_func, {'x','dx','ddx'}, 1:n_node, -Inf, 0.0, 'Nonlinear');    
%     
end