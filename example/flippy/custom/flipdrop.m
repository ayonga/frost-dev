function nlp = flipdrop(nlp, bounds, varargin)
if numel(varargin)<1
    %% starting and ending position
    x_start = [2.00713, 0.43068, -0.59139, 0.73060, 0.57968, 0.00806];
    p_start = [endeffx_sca_LR(x_start),endeffy_sca_LR(x_start),endeffz_sca_LR(x_start)];
    %%  Specify the starting and the ending orienation
    o_start   = [o_endeffx_LR(x_start),o_endeffy_LR(x_start),o_endeffz_LR(x_start)];
else
    pose_start = varargin{1};
%     pose_end = varargin{2};
    %% starting and ending position
    p_start = pose_start.position;
    %%  Specify the starting and the ending orienation
    o_start   = pose_start.orientation;
    
    qstart = varargin{3};
    dqstart = varargin{5};
end

    %% add aditional custom constraints
    
    plant = nlp.Plant;
    spatula_specs = getSpatulaSpecs();
    boxes = getGrillAndTableSpecs();
    
%%  Specify burger location. Starting position of spatula is 2cm above burger location

    n_node = nlp.NumNode;
    inflection_node = round(0.65*n_node);
  
    %% configuration constraints
    
    x = plant.States.x;
    dx = plant.States.dx;
    ddx = plant.States.ddx;
   
%% configuration constraints
    if ~isempty(qstart)
        q_init_L = qstart -0.01;
        q_init_U = qstart +0.01;
        configq = SymFunction(['configq_' plant.Name],x,{x});
        addNodeConstraint(nlp, configq, {'x'}, 'first', q_init_L, q_init_U, 'Nonlinear');
    end 
    if ~isempty(dqstart)
        dq_init_L = dqstart -0.05;
        dq_init_U = dqstart +0.05;
        configdq = SymFunction(['configdq_' plant.Name],dx,{dx});
%         addNodeConstraint(nlp, configdq, {'dx'}, 'first', dq_init_L, dq_init_U, 'Nonlinear');
        addNodeConstraint(nlp, configdq, {'dx'}, 'first', -0.1, 0.1, 'Nonlinear');
%         addNodeConstraint(nlp, configdq, {'dx'}, 'last', -0.02, 0.02, 'Nonlinear');
    end    

%     q_final_L = bounds.states.x.lb;
%     q_final_U = bounds.states.x.ub;
%     q_final_L(4) = -pi/3;
%     q_final_U(4) =  pi/3;
%     q_final_L(5) = 0;
    
    
%     dq_final_L = bounds.states.dx.lb;
%     dq_final_U = bounds.states.dx.ub;
    
%     grill_mid_y = boxes.grill_box.p_max(2)/2 + boxes.grill_box.p_min(2)/2;
    
%     if p_start(2) - grill_mid_y > 0
% %         q_final_L(end) = -1.5*pi;
% %         q_final_U(end) = -pi/2;
%         
%         dq_final_U(end) = 0.0;
%     else
% %         q_final_L(end) = pi/2;
% %         q_final_U(end) = 1.5*pi;
%         
%         dq_final_L(end) = 0.0;
%     end
%         
% %     addNodeConstraint(nlp, configq, {'x'}, 'last', q_final_L, q_final_U, 'Nonlinear');
%     
%     configdq = SymFunction(['configdq_' plant.Name],dx,{dx});
%     addNodeConstraint(nlp, configdq, {'dx'}, 'last', dq_final_L, dq_final_U, 'Nonlinear');
    
    %%
    spatula_link = plant.Links(getLinkIndices(plant, 'link_6'));
    link_5 = plant.Links(getLinkIndices(plant, 'link_5'));

    spatula_tool_frame = spatula_link.Reference;

    spatula = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',spatula_specs.Offset,... 
        'R',spatula_specs.R ... 
        );
                            
    p_spatula = getCartesianPosition(plant,spatula);
    p_link5  = getCartesianPosition(plant,link_5);
    
%% This is z position of end effector    
    basez_offset_wrt_origin =  getBaseOffsetwrtOrigin(); % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp,p_z_func,{'x'},'except-terminal',boxes.grill_box.p_min(3),boxes.grill_box.p_max(3),'Nonlinear');
    addNodeConstraint(nlp,p_z_func,{'x'},'first',p_start(3),p_start(3),'Nonlinear');
%     addNodeConstraint(nlp,p_z_func,{'x'},'last',p_start(3)+0.02,p_start(3)+0.4,'Nonlinear');

%% This is x position of end effector
    p_x = p_spatula(1);
    p_x_min = max(boxes.grill_box.p_min(1),p_start(1)-0.05);
    p_x_max = min(boxes.grill_box.p_max(1),p_start(1)+0.05);
    
    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp,p_x_func,{'x'},'except-terminal',p_x_min,p_x_max,'Nonlinear');
    addNodeConstraint(nlp,p_x_func,{'x'},'first',p_start(1),p_start(1),'Nonlinear');
    addNodeConstraint(nlp,p_x_func,{'x'},'last',p_start(1),p_start(1),'Nonlinear');

%% This is y position of end effector
    p_y = p_spatula(2);
    p_y_min = max(boxes.grill_box.p_min(2),p_start(2)-0.3);
    p_y_max = min(boxes.grill_box.p_max(2),p_start(2)+0.3);
    
    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp,p_y_func,{'x'},'except-terminal',p_y_min,p_y_max,'Nonlinear');
    addNodeConstraint(nlp,p_y_func,{'x'},'first',p_start(2),p_start(2),'Nonlinear');
    addNodeConstraint(nlp,p_y_func,{'x'},'last',p_start(2),p_start(2),'Nonlinear');
    
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
%     addNodeConstraint(nlp, vx_func, {'x','dx'}, inflection_node, 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vy_func, {'x','dx'}, inflection_node, -0.1, 0.1, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'first', 0, 0, 'Nonlinear');
    addNodeConstraint(nlp, vz_func, {'x','dx'}, 'last', -Inf, -0.05, 'Nonlinear');
    
    
    % acceleration functions
%     ax_func = SymFunction(['endeffax_sca_' plant.Name],a_x,{x,dx,ddx});
%     ay_func = SymFunction(['endeffay_sca_' plant.Name],a_y,{x,dx,ddx});
%     az_func = SymFunction(['endeffaz_sca_' plant.Name],a_z,{x,dx,ddx});

%     addNodeConstraint(nlp, ax_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, ay_func, {'x','dx','ddx'}, 'first', -Inf, Inf , 'Nonlinear');
%     addNodeConstraint(nlp, az_func, {'x','dx','ddx'}, 'first', -Inf, Inf, 'Nonlinear');
    

    g = -9.81; % acceleration due to gravity - a constant
    mu = 0.18; % coefficient of restitution
    
    R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
            
    normal_vector_spatula = R_vec_spatula([3,6,9]); %last column of R matrix
    front_vector_spatula = R_vec_spatula([1,4,7]); % first column of R matrix
    
    dot_product_normal_to_acceleration = normal_vector_spatula ...
                                         * [a_x;
                                            a_y;
                                            a_z-g] / sqrt(a_x^2 + a_y^2 + (a_z-g)^2);

	normal_vector = SymFunction(['normal_vector_' plant.Name],normal_vector_spatula,{x});
	front_vector = SymFunction(['front_vector_' plant.Name],front_vector_spatula,{x});
    
    %     addNodeConstraint(nlp, normal_vector, {'x'}, 'first', [-0.1,-0.1,0.9], [0.1,0.1,1], 'Nonlinear');
    addNodeConstraint(nlp, normal_vector, {'x'}, 'last', [-0.5,-0.5,-1], [0.0,0.5,-0.8], 'Nonlinear');
    addNodeConstraint(nlp, front_vector, {'x'}, 'all', [0.6,-1,-1], [1,1,1], 'Nonlinear');
    
    slipping_func = SymFunction(['slipping_sca_' plant.Name],dot_product_normal_to_acceleration,{x,dx,ddx});
    addNodeConstraint(nlp, slipping_func, {'x','dx','ddx'}, 1:inflection_node, cos(mu), 1, 'Nonlinear');
    
%% link 5 position constraints are given here
    p_z_link5 = p_link5(3) - basez_offset_wrt_origin;
    p_z_link5_func = SymFunction(['p_z_link5_sca_' plant.Name],p_z_link5,{x});
    addNodeConstraint(nlp, p_z_link5_func, {'x'}, 'all', 0.22, 0.5, 'Nonlinear');
    
end