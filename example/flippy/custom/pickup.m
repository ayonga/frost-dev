function nlp = pickup(nlp, bounds, varargin)
if numel(varargin)<1
    %% starting and ending position
    p_start = [0.7, 0.0, 0.0851];
    p_end = [0.76, 0.0, 0.0851];
    %%  Specify the starting and the ending orienation
    o_start   = [0,0.314,0];
    o_end = [0,0,0];
else
    pose_start = varargin{1};
    pose_end = varargin{2};
    %% starting and ending position
    p_start = pose_start.position;
    p_end = pose_end.position;
    %%  Specify the starting and the ending orienation
    o_start   = pose_start.orientation;
    o_end = pose_end.orientation;
    
    qstart = varargin{3};
    dqstart = varargin{5};
end
    spatula_specs = getSpatulaSpecs();
    %% configuration constraints
    plant = nlp.Plant;
    x = plant.States.x;
    dx = plant.States.dx;
    ddx = plant.States.ddx;

%% configuration constraints
    if ~isempty(qstart)
        q_init_L = qstart -0.05;
        q_init_U = qstart +0.05;
        configq = SymFunction(['configq_' plant.Name],x,{x});
        addNodeConstraint(nlp, configq, {'x'}, 'first', q_init_L, q_init_U, 'Nonlinear');
    end    
    if ~isempty(dqstart)
        dq_init_L = dqstart -0.1;
        dq_init_U = dqstart +0.1;
        configdq = SymFunction(['configdq_' plant.Name],dx,{dx});
%         addNodeConstraint(nlp, configdq, {'dx'}, 'first', dq_init_L, dq_init_U, 'Nonlinear');
        addNodeConstraint(nlp, configdq, {'dx'}, 'first', -0.03, 0.03, 'Nonlinear');
        addNodeConstraint(nlp, configdq, {'dx'}, 'last', -0.02, 0.02, 'Nonlinear');
    end
    %%
    spatula_link = plant.Links(getLinkIndices(plant, 'link_6'));

    spatula_tool_frame = spatula_link.Reference;

    spatula = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',spatula_specs.Offset,... 
        'R',spatula_specs.R ... 
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
    basez_offset_wrt_origin =  getBaseOffsetwrtOrigin(); % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 'except-terminal', p_start(3), p_end(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'first', p_start(3), p_start(3), 'Nonlinear');
    addNodeConstraint(nlp, p_z_func, {'x'}, 'last', p_end(3), p_end(3), 'Nonlinear');
    
    %% these are slipping constraints being added

    v_x = jacobian(p_spatula(1), x)*dx ;
    v_y = jacobian(p_spatula(2), x)*dx ;
    v_z = jacobian(p_spatula(3), x)*dx ;
    
%     velocity functions
    vx_func = SymFunction(['endeffvx_sca_' plant.Name],v_x,{x,dx});
    vy_func = SymFunction(['endeffvy_sca_' plant.Name],v_y,{x,dx});
    vz_func = SymFunction(['endeffvz_sca_' plant.Name],v_z,{x,dx});

    addNodeConstraint(nlp, vx_func, {'x','dx'}, 'all', -0.1, 0.1, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, 'all', -0.1, 0.1, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'all', -0.1, 0.1, 'Nonlinear');
%     
%     addNodeConstraint(nlp, vx_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, vy_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
%     addNodeConstraint(nlp, vz_func, {'x','dx'}, 'last', 0, 0, 'Nonlinear');
    
    %%
    % get orientation of the end effector in terms of euler angles
    orientation = getRelativeEulerAngles(plant,spatula);
    o_x = orientation(1);
    o_y = orientation(2);
    o_z = orientation(3);


    % these are the ee constraints on the end effector
    o_endeffx = SymFunction(['o_endeffx_' plant.Name],o_x,{x});
    o_endeffy = SymFunction(['o_endeffy_' plant.Name],o_y,{x});
    o_endeffz = SymFunction(['o_endeffz_' plant.Name],o_z,{x});

    addNodeConstraint(nlp, o_endeffx, {'x'}, 'except-terminal', o_start(1)-0.03, o_start(1)+0.03, 'Nonlinear');
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'first', o_start(1), o_start(1), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffx, {'x'}, 'last',   o_end(1), o_end(1), 'Nonlinear');

    addNodeConstraint(nlp, o_endeffy, {'x'}, 'all', o_end(2), o_start(2), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'first', o_start(2), o_start(2), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffy, {'x'}, 'last',   o_end(2), o_end(2), 'Nonlinear');

    addNodeConstraint(nlp, o_endeffz, {'x'}, 'except-terminal', o_start(3)-0.03, o_start(3)+0.03, 'Nonlinear'); 
    addNodeConstraint(nlp, o_endeffz, {'x'}, 'first', o_start(3), o_start(3), 'Nonlinear');
    addNodeConstraint(nlp, o_endeffz, {'x'}, 'last',   o_end(3), o_end(3), 'Nonlinear');


%% these are slipping constraints being added

   
    
    % acceleration functions
%     ax_func = SymFunction(['endeffax_sca_' plant.Name],a_x,{x,dx,ddx});
%     ay_func = SymFunction(['endeffay_sca_' plant.Name],a_y,{x,dx,ddx});
%     az_func = SymFunction(['endeffaz_sca_' plant.Name],a_z,{x,dx,ddx});

%     addNodeConstraint(nlp, ax_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, ay_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, az_func, {'x','dx','ddx'}, 'first', -Inf, Inf, 'Nonlinear');
    

%     R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
            
%     normal_vector_spatula = R_vec_spatula([3,6,9]); %last column of R matrix
    

% 	normal_vector = SymFunction(['normal_vector_' plant.Name],normal_vector_spatula,{x});
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'all', [-0.2,-0.2,0.8], [0.2,0.2,1], 'Nonlinear');
    
    
end