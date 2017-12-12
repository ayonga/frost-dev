function nlp = joint2joint(nlp, bounds, varargin)
if numel(varargin)<1
    qstart = [1.5767    0.9437   -0.3532    0.0069    0.9534    0.3995];
    qfinal = [1.5786    0.52369  -0.75852   0.012085  0.44462   0.39629];
    
else
    qstart = varargin{1};
    qfinal = varargin{2};
    dqstart = varargin{3};
    p_start = [endeffx_sca_LR(qstart),endeffy_sca_LR(qstart),endeffz_sca_LR(qstart)];
    
end

%% add aditional custom constraints
    
    plant = nlp.Plant;
    spatula_specs = getSpatulaSpecs();
    boxes = getGrillAndTableSpecs();
    
%%  Specify burger location. Starting position of spatula is 2cm above burger location

%     n_node = nlp.NumNode;
%     inflection_node = round(0.6*n_node);
      
    %% configuration constraints
    x = plant.States.x;
    dx = plant.States.dx;
    
%% configuration constraints
    if ~isempty(qstart)
        q_init_L = qstart -0.01;
        q_init_U = qstart +0.01;
        q_final_L = qfinal -0.02;
        q_final_U = qfinal +0.02;
        
        configq = SymFunction(['configq_' plant.Name],x,{x});
        addNodeConstraint(nlp, configq, {'x'}, 'first', q_init_L, q_init_U, 'Nonlinear');
        addNodeConstraint(nlp, configq, {'x'}, 'last', q_final_L, q_final_U, 'Nonlinear');
    end 
    if ~isempty(dqstart)
        configdq = SymFunction(['configdq_' plant.Name],dx,{dx});
%         addNodeConstraint(nlp, configdq, {'dx'}, 'first', -0.03, 0.03, 'Nonlinear');
        addNodeConstraint(nlp, configdq, {'dx'}, 'last', -0.02, 0.02, 'Nonlinear');
    end    

%     q_final_L = bounds.states.x.lb;
%     q_final_U = bounds.states.x.ub;
%     q_final_L(4) = -pi/3;
%     q_final_U(4) =  pi/3;
%     q_final_L(5) = 0;
            
%     addNodeConstraint(nlp, configq, {'x'}, 'last', q_final_L, q_final_U, 'Nonlinear');
    
   
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
    
%     spatula_ledge = CoordinateFrame(...
%         'Name','SpatulaTool',...
%         'Reference',spatula_tool_frame,...
%         'Offset',[-0.014 0.04 0.208],... 
%         'R',[0,-2 * pi/3,-23*pi/180]... 
%         );
%     
%     spatula_redge = CoordinateFrame(...
%          'Name','SpatulaTool',...
%          'Reference',spatula_tool_frame,...
%         'Offset',[-0.014 -0.04 0.208],... 
%         'R',[0,-2 * pi/3,-23*pi/180]... 
%          );
     
    p_spatula = getCartesianPosition(plant,spatula);
%     p_link6  = getCartesianPosition(plant,spatula_link);
    p_link5  = getCartesianPosition(plant,link_5);

%     p_lspatula = getCartesianPosition(plant,spatula_ledge);
%     p_rspatula = getCartesianPosition(plant,spatula_redge);

    %% This is x position of end effector
    p_x = p_spatula(1);
    p_x_min = max(boxes.grill_box.p_min(1),p_start(1)-0.05);
    p_x_max = min(boxes.grill_box.p_max(1),p_start(1)+0.05);

    p_x_func = SymFunction(['endeffx_sca_' plant.Name],p_x,{x});
    addNodeConstraint(nlp, p_x_func, {'x'}, 'all', p_x_min, p_x_max, 'Nonlinear');
    
    %% This is y position of end effector
    p_y = p_spatula(2);
    p_y_min = max(boxes.grill_box.p_min(2),p_start(2)-0.3);
    p_y_max = min(boxes.grill_box.p_max(2),p_start(2)+0.3);

    p_y_func = SymFunction(['endeffy_sca_' plant.Name],p_y,{x});
    addNodeConstraint(nlp, p_y_func, {'x'}, 'all', p_y_min, p_y_max, 'Nonlinear');
    
    %% This is z position of end effector
    basez_offset_wrt_origin =  getBaseOffsetwrtOrigin(); % to make base bottom zero
    p_z = p_spatula(3) - basez_offset_wrt_origin;
    p_z_func = SymFunction(['endeffz_sca_' plant.Name],p_z,{x});
    addNodeConstraint(nlp, p_z_func, {'x'}, 'all', 0.16, 0.4, 'Nonlinear');
    
%     %% link 6 position constraints are given here
%     p_z_link6 = p_link6(3) - basez_offset_wrt_origin;
%     p_z_link6_func = SymFunction(['p_z_link6_sca_' plant.Name],p_z_link6,{x});
%     addNodeConstraint(nlp, p_z_link6_func, {'x'}, 'all', 0.16, 0.5, 'Nonlinear');

    %% link 5 position constraints are given here
    p_z_link5 = p_link5(3) - basez_offset_wrt_origin;
    p_z_link5_func = SymFunction(['p_z_link5_sca_' plant.Name],p_z_link5,{x});
    addNodeConstraint(nlp, p_z_link5_func, {'x'}, 'all', 0.2, 0.5, 'Nonlinear');
%     addNodeConstraint(nlp, p_z_link5_func, {'x'}, round(n_node/2), 0.4, 0.5, 'Nonlinear');
%% these are slipping constraints being added

    v_x = jacobian(p_spatula(1), x)*dx ;
    v_y = jacobian(p_spatula(2), x)*dx ;
    v_z = jacobian(p_spatula(3), x)*dx ;
    
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

% %%
%     
%     spatula_link = plant.Links(getLinkIndices(plant, 'link_6'));
%     
%     spatula_tool_frame = spatula_link.Reference;
% 
%     spatula = CoordinateFrame(...
%         'Name','SpatulaTool',...
%         'Reference',spatula_tool_frame,...
%         'Offset',spatula_specs.Offset,... 
%         'R',spatula_specs.R ... 
%         );
%                             
%     R_vec_spatula = getRelativeRigidOrientation(plant,spatula);
%             
%     normal_vector_spatula = R_vec_spatula([3,6,9]); %last column of R matrix
%     
%     normal_vector = SymFunction(['normal_vector_' plant.Name],normal_vector_spatula,{x});
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'first', [-1,0.0,-1], [0.0,1,-0.65], 'Nonlinear');
%     addNodeConstraint(nlp, normal_vector, {'x'}, round(0.4*n_node), [-1,0.0,-1], [0.0,1,-0.65], 'Nonlinear');
%     addNodeConstraint(nlp, normal_vector, {'x'}, 'last', [-0.1,-0.1,0.9], [0.1,0.1,1], 'Nonlinear');
%      
%% Left spatula edge constraints
%     p_lz_spatula_func = SymFunction(['p_lz_spatula_sca_' plant.Name],p_lspatula(3),{x});
%     addNodeConstraint(nlp, p_lz_spatula_func, {'x'}, 'all', 0.16, 0.4, 'Nonlinear');
   
%% Right spatula edge constraints
%     p_rz_spatula_func = SymFunction(['p_rz_spatula_sca_' plant.Name],p_rspatula(3),{x});
%     addNodeConstraint(nlp, p_rz_spatula_func, {'x'}, 'all', 0.16, 0.4, 'Nonlinear');
   
end