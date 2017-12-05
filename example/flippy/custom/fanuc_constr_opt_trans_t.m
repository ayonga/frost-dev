function nlp = fanuc_constr_opt_trans_t(nlp, bounds, varargin)
    A2B =0;
    p_A = [0.4, 0.8, 0.25]; % this is point A
    o_A = [0,0,pi/2];        % this is orientation A
    p_B = [-0.2, 0.8, 0.25];  % this is point B
    o_B = [0,0,pi/2];            % this is orientation B
%%  Specify the starting and the ending position
    if A2B
        p_start = p_A;
        p_end = p_B;
        %%  Specify the starting and the ending orienation
        o_start   = o_A;
        o_end = o_B;
    else
%%  Specify the starting and the ending position
        p_start = p_B;
        p_end = p_A;
        %%  Specify the starting and the ending orienation
        o_start = o_B;
        o_end   = o_A;
    end

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
%     n_node = nlp.NumNode;
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
    addNodeConstraint(nlp, p_z_func, {'x'}, 'except-terminal', 0.1, 0.4, 'Nonlinear');
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

    addNodeConstraint(nlp, vx_func, {'x','dx'}, 'except-terminal', -0.6, 0.6, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, 'except-terminal', -0.6, 0.6, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'except-terminal', -0.6, 0.6, 'Nonlinear');

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
%     tangent_vector_spatula_x = R_vec_spatula([1,4,7]);
%     tangent_vector_spatula_y = R_vec_spatula([2,5,8]);
    
    
    dot_product_normal_to_acceleration = normal_vector_spatula ...
                                         * [a_x;
                                            a_y;
                                            a_z-g] / sqrt(a_x^2 + a_y^2 + (a_z-g)^2);

    slipping_func = SymFunction(['slipping_sca_' plant.Name],dot_product_normal_to_acceleration,{x,dx,ddx});
    addNodeConstraint(nlp, slipping_func, {'x','dx','ddx'}, 'all', cos(mu), 1, 'Nonlinear');
    
    
%     normal_vector = SymFunction(['normal_vector_' plant.Name],normal_vector_spatula,{x});
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'all', [0,0,0.2], [1,1,1], 'Nonlinear');

%     tangent_vector_spatula_x = SymFunction(['tangent_vector_x_' plant.Name],tangent_vector_spatula_x,{x});
%     addNodeConstraint(nlp, tangent_vector_spatula_x, {'x'}, 'all', [0,0,0.2], [1,1,1], 'Nonlinear');
% 
%     tangent_vector_spatula_y = SymFunction(['tangent_vector_y_' plant.Name],tangent_vector_spatula_y,{x});
%     addNodeConstraint(nlp, tangent_vector_spatula_y, {'x'}, 'all', [0,0,0.2], [1,1,1], 'Nonlinear');

    
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
%     addNodeConstraint(nlp, lslipping_func, {'x','dx','ddx'}, 1:n_node, cos(mu), 1, 'Nonlinear');
    
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
%     addNodeConstraint(nlp, rslipping_func, {'x','dx','ddx'}, 1:n_node, cos(mu), 1, 'Nonlinear');

%% Amigo Please configure collsion constraints here. okay?
%     lineobstacleobject = struct();
%     lineobstacleobject.nLines = 2;
%     lineobstacleobject.Lines(1).StartPoint = [0.2,0.7,0];
%     lineobstacleobject.Lines(1).EndPoint = [0.2,0.7,1];
%     lineobstacleobject.Lines(2).StartPoint = [-0.2,0.6,0.11];
%     lineobstacleobject.Lines(2).EndPoint =   [0.4,0.6,0.11];
    
    planeobstacleobject = struct();
    planeobstacleobject.nPlanes = 4;
    planeobstacleobject.Planes(1).normal = [-1,0,0];
    planeobstacleobject.Planes(1).point = [0.8,0.4,0.5];
    planeobstacleobject.Planes(2).normal = [0,-1,0];
    planeobstacleobject.Planes(2).point = [0.8,0.4,0.5];
    planeobstacleobject.Planes(3).normal = [1,0,0];
    planeobstacleobject.Planes(3).point = [1.1,0.42,0.5];
    planeobstacleobject.Planes(4).normal = [0,1,0];
    planeobstacleobject.Planes(4).point = [1.1,0.42,0.5];
    
    
%     ConfigureCollisionConstraints(nlp,planeobstacleobject);
%% okay after realizing that this collision avoidancr crap does not work!!! 
% let's try this crap: gaussian function --- god save me!!! (if he
% exists)!! of course
% here is a gaussian function in y coordinate---obstacle to the left of the
% robot
% a = 0.4; % some constants for gaussian 
% b = 0.1;
% c = 10;
% gaussian_value = 1 -  a * exp(-(p_x - b).^2 * c^2) - p_y;
% gaussian_func = SymFunction(['gaussian_sca_' plant.Name],gaussian_value,{x});
% addNodeConstraint(nlp, gaussian_func, {'x'}, 'all', 0, Inf, 'Nonlinear');

% grill left border is defined via sigmoid
depth_far_left = 1; % far edge of left border of the grill
depth_near_left = 0.6; % near edge of the left border of the grill
y_pos_left  = 0.16; % y pos of the left border of the grill
a_left = depth_far_left - depth_near_left; % amplitude of the sigmoid
b_left = y_pos_left; % mean of gaussian
c_left = 100; % attenuation factor higher the value of c more slender is the sigmoid
sigmoid_value_left = depth_near_left + a_left * exp((p_y - b_left) * c_left) / (exp((p_y - b_left) * c_left) + 1) - p_x;
sigmoid_func_left = SymFunction(['sigmoid_sca_left_' plant.Name],sigmoid_value_left,{x});
% addNodeConstraint(nlp, sigmoid_func_left, {'x'}, 'all', 0, Inf, 'Nonlinear');

% grill right border is defined via sigmoid
depth_far_right = 1; % far edge of right border of the grill
depth_near_right = 0.6; % near edge of the right border of the grill
y_pos_right  = 0.16; % y pos of the right border of the grill
a_right = depth_far_right - depth_near_right; % amplitude of the sigmoid
b_right = y_pos_right; % mean of gaussian
c_right = 100; % attenuation factor higher the value of c more slender is the sigmoid
sigmoid_value_right = depth_near_right + a_right * exp(-(p_y - b_right) * c_right) / (exp(-(p_y - b_right) * c_right) + 1) - p_x;
sigmoid_func_right = SymFunction(['sigmoid_sca_right_' plant.Name],sigmoid_value_right,{x});
% addNodeConstraint(nlp, sigmoid_func_right, {'x'}, 'all', 0, Inf, 'Nonlinear');


%% Costs are added here
    
%     nstate = plant.numState;
%     nlambda = nstate*lineobstacleobject.nLines;
%     
%     u = plant.Inputs.Control.u;
%     
%     lmbda = SymVariable('lmbda',[nlambda,1]);
%    
%     
%     u2r = tovector(norm(u).^2);
%     u2r_fun = SymFunction(['torque_' plant.Name],u2r,{u});
%     addRunningCost(nlp,u2r_fun,{'u'});
    
end