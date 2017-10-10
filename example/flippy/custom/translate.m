function nlp = translate(nlp, bounds, varargin)

    p_A = [-0.2, 0.8, 0.25]; % this is point A
    p_B = [0.4, 0.8, 0.25];  % this is point B
    %% starting and ending position
    p_start = p_A;
    p_end = p_B;
    %%  Specify the starting and the ending orienation
    o_start   = [0,0,pi/2];
    o_end = [0,0,pi/2];
    
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
%     n_node = nlp.NumNode;
    p_x = p_spatula(1);
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 'first', p_start(1), p_start(1), 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, 'last', p_end(1), p_end(1), 'Nonlinear');
    addNodeConstraint(nlp, p_x_func, {'x'}, 'except-terminal', -Inf, Inf, 'Nonlinear');

%% This is y position of end effector
    p_y = p_spatula(2);
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 'first', p_start(2), p_start(2), 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, 'last', p_end(2), p_end(2), 'Nonlinear');
    addNodeConstraint(nlp, p_y_func, {'x'}, 'except-terminal', -Inf, Inf, 'Nonlinear');

%% This is z position of end effector    
    basez_offset_wrt_origin =  0.3381; % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 'first', p_start(3), p_start(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'last', p_end(3), p_end(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'except-terminal', -Inf, Inf, 'Nonlinear');

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

    addNodeConstraint(nlp, vx_func, {'x','dx'}, 'except-terminal', -0.3, 0.3, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, 'except-terminal', -0.3, 0.3, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'except-terminal', -0.3, 0.3, 'Nonlinear');

    % acceleration functions

    g = -9.81; % acceleration due to gravity - a constant
    mu = 0.16; % coefficient of restitution
    
    R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
            
    normal_vector_spatula = R_vec_spatula([3,6,9]);
    
    dot_product_normal_to_acceleration = normal_vector_spatula ...
                                         * [a_x;
                                            a_y;
                                            a_z-g] / sqrt(a_x^2 + a_y^2 + (a_z-g)^2);

    slipping_func = SymFunction(['slipping_sca_' plant.Name],dot_product_normal_to_acceleration,{x,dx,ddx});
    addNodeConstraint(nlp, slipping_func, {'x','dx','ddx'}, 'all', cos(mu), 1, 'Nonlinear');
    
    
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

    addNodeConstraint(nlp, o_endeffy, {'x'}, 'first', o_start(2), o_start(2), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'last',   o_end(2), o_end(2), 'Nonlinear');

    addNodeConstraint(nlp, o_endeffz, {'x'}, 'first', o_start(3), o_start(3), 'Nonlinear'); 
    addNodeConstraint(nlp, o_endeffz, {'x'}, 'last', o_end(3), o_end(3), 'Nonlinear'); 
    
%% Costs are added here
    
    u = plant.Inputs.Control.u;
    
    u2r = tovector(norm(u).^2);
    u2r_fun = SymFunction(['torque_' plant.Name],u2r,{u});
    addRunningCost(nlp,u2r_fun,{'u'});
    
end