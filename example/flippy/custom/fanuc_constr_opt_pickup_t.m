function nlp = fanuc_constr_opt_pickup_t(nlp, bounds, varargin)
    
%%  Specifications for the pickup
    grill_height = 0.085;
    total_thrust_length = 0.08;
    slide_lift = 0.02;
    
%% get the argument inputs
    if nargin < 3
        p_burger_location = [0., 0.76, 0.085]; % dont change this value
    else
        if numel(varargin(1)) < 3
            error('Three values needed for x,y,z positions for specifying burger location');
        else
            p_burger_location = varargin(1);
            if max(abs(p_burger_location)) < 1e-10, error('Burger cannot be in the origin'); end
        end
        if p_burger_location(3) < grill_height
            error(['Specify position above ', num2str(grill_height), ' m']);
        end
    end
%%
%     spatula_height_offset_from_burger = spatula_length*sin(approach_tilt)/2;
    approach_yaw = atan2(p_burger_location(2),p_burger_location(1));
%     approach_vector = [p_burger_location(1),p_burger_location(2)]/...
%                     sqrt(p_burger_location(1)^2+p_burger_location(2)^2);
    
%     p_start = [p_burger_location(1)-approach_offset*cos(approach_yaw),...
%             p_burger_location(2)-approach_offset*sin(approach_yaw),...
%             p_burger_location(3) + spatula_height_offset_from_burger];
    
    p_start = [p_burger_location(1),...
               p_burger_location(2),...
               p_burger_location(3)];

    p_end = [p_start(1)+(total_thrust_length)*cos(approach_yaw),...
             p_start(2)+(total_thrust_length)*sin(approach_yaw),...
             p_burger_location(3)+slide_lift];
  
%%  Specify the starting and the ending orienation
%     o_start   = [0,approach_tilt,approach_yaw];
    o_start   = [0,0,approach_yaw];
    o_end   = [0,0,approach_yaw];

%% % add aditional custom constraints
    
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
    
    p_spatula = getCartesianPosition(plant,spatula);

%% This is x position of end effector
    p_x = p_spatula(1);
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 'first', p_start(1), p_start(1), 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, 'last', p_end(1), p_end(1), 'Nonlinear');

    %% This is y position of end effector
    p_y = p_spatula(2);
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 'first', p_start(2), p_start(2), 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, 'last', p_end(2), p_end(2), 'Nonlinear');
    
%% This is z position of end effector    
    basez_offset_wrt_origin =  0.3381; % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 'first', p_start(3), p_start(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'last', p_end(3), p_end(3), 'Nonlinear');
    
    %% these are slipping constraints being added

    v_x = jacobian(p_spatula(1), x)*dx;
    v_y = jacobian(p_spatula(2), x)*dx;
    v_z = jacobian(p_spatula(3), x)*dx;
    
    a_x = jacobian(v_x,dx)*ddx + jacobian(v_x,x)*dx;
    a_y = jacobian(v_y,dx)*ddx + jacobian(v_y,x)*dx;
    a_z = jacobian(v_z,dx)*ddx + jacobian(v_z,x)*dx;
    
%     velocity functions
%     vx_func = SymFunction(['endeffvx_sca_' plant.Name],v_x,{x,dx});
%     vy_func = SymFunction(['endeffvy_sca_' plant.Name],v_y,{x,dx});
%     vz_func = SymFunction(['endeffvz_sca_' plant.Name],v_z,{x,dx});
    
%     dot_product_tangent_to_velocity = tangent_to_approach_vector*[v_x,v_y]';
%     dot_product_tangent_to_velocity = v_x*sin(approach_yaw) - v_y * cos(approach_yaw);
%     dot_product_tangent_to_velocity_func = SymFunction(['tangentdotvel_' plant.Name],...
%                                 dot_product_tangent_to_velocity,{x,dx});
                            
%     addNodeConstraint(nlp, dot_product_tangent_to_velocity_func, ...
%             {'x','dx'}, 'first', 0, 0, 'Nonlinear');

%     addNodeConstraint(nlp, vx_func, {'x','dx'}, 'all', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, vy_func, {'x','dx'}, 'all', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, vz_func, {'x','dx'}, 'all', 0, 0, 'Nonlinear');
    
%     addNodeConstraint(nlp, vx_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, vy_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, vz_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');

    % acceleration functions
%     ax_func = SymFunction(['endeffax_sca_' plant.Name],a_x,{x,dx,ddx});
%     ay_func = SymFunction(['endeffay_sca_' plant.Name],a_y,{x,dx,ddx});
%     az_func = SymFunction(['endeffaz_sca_' plant.Name],a_z,{x,dx,ddx});

%     addNodeConstraint(nlp, ax_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, ay_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, az_func, {'x','dx','ddx'}, 'first', -Inf, Inf, 'Nonlinear');
    

    g = -9.81; % acceleration due to gravity - a constant
    mu = 0.2; % coefficient of restitution
    
    R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
            
    normal_vector_spatula = R_vec_spatula([3,6,9]);
    
    dot_product_normal_to_acceleration = normal_vector_spatula ...
                                         * [a_x;
                                            a_y;
                                            a_z-g] / sqrt(a_x^2 + a_y^2 + (a_z-g)^2);

    slipping_func = SymFunction(['slipping_sca_' plant.Name],dot_product_normal_to_acceleration,{x,dx,ddx});
%     addNodeConstraint(nlp, slipping_func, {'x','dx','ddx'}, round(0.2*n_node):n_node_mid, 0, cos(mu), 'Nonlinear');
    
    
    normal_vector = SymFunction(['normal_vector_' plant.Name],normal_vector_spatula,{x});
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'except-terminal', [0,0,0.2], [1,1,1], 'Nonlinear');
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'first', [0,0,0.95], [0.05,0.05,1], 'Nonlinear');
%     addNodeConstraint(nlp, normal_vector, {'x'}, round(0.2*n_node), [0,0.3,0.94], [0,0.3089,0.96], 'Nonlinear');
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'last', [0,0,0.95], [0.05,0.05,1], 'Nonlinear');
    
    
    % get orientation of the end effector in terms of euler angles
    orientation = getRelativeEulerAngles(plant,spatula);
    o_x = orientation(1);
    o_y = orientation(2);
    o_z = orientation(3);


    % these are the ee constraints on the end effector
    o_endeffx = SymFunction(['o_endeffx_' plant.Name],o_x,{x});
    o_endeffy = SymFunction(['o_endeffy_' plant.Name],o_y,{x});
    o_endeffz = SymFunction(['o_endeffz_' plant.Name],o_z,{x});

    addNodeConstraint(nlp, o_endeffx, {'x'}, 'all', o_start(1), o_start(1), 'Nonlinear');

    addNodeConstraint(nlp, o_endeffy, {'x'}, 'first', o_start(2), o_start(2), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'last',   o_end(2)-0.2, o_end(2)-0.1, 'Nonlinear');

    addNodeConstraint(nlp, o_endeffz, {'x'}, 'all', o_start(3), o_start(3), 'Nonlinear');


end