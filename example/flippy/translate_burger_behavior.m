function [Behavior] = translate_burger_behavior(flippy,cur,varargin)
%% some constants - should be made part of flippy grill properties in future
p_home = [0.57,0.16,0.25];
o_home = [0,0,0];

% grill and table specifications : in future all this should be in a different struct
grill_left_y = 0.17; % here left means left side of the robot
grill_right_y = -0.64; % right side of the robot
grill_near_x = 0.55; % closest x position of the grill
grill_far_x = 0.9; % farthest x position of the grill
grill_height = 0.085; % height of the grill w.r.t. base of robot
table_left_x = -0.4; % left side of the robot
table_right_x = 0.6; % right side of the robot
table_height = 0.11; % height of the table w.r.t. base of robot
table_near_y = 0.15; % closest x position of the grill
table_far_y = 0.9; % farthest x position of the grill
table_max_height = 0.7; % maximum height w.r.t. base of fanuc
grill_max_height = 0.7; % maximum height w.r.t. base of fanuc

boxes.table_box.p_min = [table_left_x, table_near_y, table_height];
boxes.table_box.p_max = [table_right_x, table_far_y, table_max_height];

boxes.grill_box.p_min = [grill_near_x, grill_right_y, grill_height];
boxes.grill_box.p_max = [grill_far_x, grill_left_y, grill_max_height];


if table_near_y > grill_left_y || grill_near_x > table_right_x
    error('It is preferred to have an overlap of the grill and table boxes. Change table grill specifications accordingly.');
end

%% assign p_start and p_end after satisfying a set of conditions provided below
numargin = numel(varargin);
if numargin < 1
    error('No starting or ending position provided. Nothing to do.');
elseif numargin < 2
    warning(['No starting position provided. Setting [',num2str(p_home),'] as the starting position']);
    p_start = p_home;
    o_start = o_home;
    if isfield(varargin{1},'position')
        p_end = varargin{1}.position;
    else
        error('Position field not provided');
    end
    if isfield(varargin{1},'orientation')
        o_end = varargin{1}.orientation;
    else
        o_end = [0,0,0];
    end
else
    if isfield(varargin{1},'position')
        p_start = varargin{1}.position;
    else
        error('Starting position field not provided');
    end
    if isfield(varargin{1},'orientation')
        o_start = varargin{1}.orientation;
    else
        o_start = [0,0,0];
    end
    
    if isfield(varargin{2},'position')
        p_end = varargin{2}.position;
    else
        error('Ending position field not provided');
    end
    if isfield(varargin{2},'orientation')
        o_end = varargin{2}.orientation;
    else
        o_end = [0,0,0];
    end
end

pose_home.position = p_home;
pose_home.orientation = o_home;
pose_start.position = p_start;
pose_start.orientation = o_start;
pose_end.position = p_end;
pose_end.orientation = o_end;

%% this defines the behavior and the subbehavior for translating burgurs from p_start to p_end
Behavior = struct();

Behavior = validateBehaviorBox(Behavior, boxes, pose_home, pose_start, pose_end);


%% The main script to run the pickup and flip burger behavior optimization

load_initial_guess = true; % not sure if this should allowed
save_solution_in_file = false; % disable saving of solutions, but it gets modified later on

%%
bounds = flippy.getLimits();

% these are hard limits. Not good to mess with these!!!

% time duration
bounds.time.t0.lb = 0; % starting time
bounds.time.t0.ub = 0;
bounds.time.tf.lb = 1.0; % terminating time
bounds.time.tf.ub = 4.0;
bounds.time.duration.lb = 1.0; % duration (optional)
bounds.time.duration.ub = 4.0;
% position, velocity, and acceleration
bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -2,   - pi ]; % -1.09 for joint 3 is the minimum limit
bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   pi, 2,    pi ];
bounds.states.dx.lb = -16*ones(1,flippy.numState);
bounds.states.dx.ub =  16*ones(1,flippy.numState);
bounds.states.ddx.lb = -800*ones(1,flippy.numState);
bounds.states.ddx.ub =  800*ones(1,flippy.numState);
% control input
bounds.inputs.Control.u.lb = - ones(1,flippy.numState)*Inf;
bounds.inputs.Control.u.ub = ones(1,flippy.numState)*Inf;


bounds.params.apos.lb = -600;
bounds.params.apos.ub = 600;
% bounds.vel.ep = 10;% y1dot = -ep*y1
bounds.pos.kp = 10; % y2ddot = -kd*y2dot - kp*y2
bounds.pos.kd = 2;

%% optimization code is here
nSubBehaviors = Behavior.nSubBehaviors;
disp(['Number of subbehaviors: ',num2str(nSubBehaviors)]);
num_grid = 10;
        
    for i=1:nSubBehaviors
       
        pose_start = Behavior.SubBehavior(i).pose_start;
        pose_end   = Behavior.SubBehavior(i).pose_end;
        sub_behavior_name = Behavior.sub_behavior_names{i};
        
        fanuc_constr_opt_str = getBehaviorName(sub_behavior_name);
        flippy.UserNlpConstraint = str2func(fanuc_constr_opt_str);

        disp(['Optimizing the subbehavior: ',Behavior.SubBehavior(i).name]);
        
        [guess_file, save_solution_in_file] = ...
            findNearestGuessFile(sub_behavior_name,cur,num_grid,pose_home,pose_start,pose_end);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Create a gait-optimization NLP based on the existing hybrid system
        %%%% model. 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        opts = struct(...%'ConstantTimeHorizon',nan(2,1),... %NaN - variable time, ~NaN, fixed time
            'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
            'EqualityConstraintBoundary',0,...
            'DistributeTimeVariable',false); % non-zero positive small value will relax the equality constraints
        nlp = TrajectoryOptimization('fanucopt', flippy, num_grid, bounds, opts);
        
        %%%%%%%%%%%%%%%%%%%%%% update the constraint properties with initial and final points %%%%%%%%%%%
        p_start = pose_start.position;
        p_end = pose_end.position;
        
        px = p_start(1);        py = p_start(2);        pz = p_start(3);
        pxe = p_end(1);         pye = p_end(2);         pze = p_end(3);
        
        arginpx.lb = px;
        arginpx.ub = px;
        updateConstrProp(nlp,'endeffx_sca_LR','first',arginpx);
        arginpy.lb = py;
        arginpy.ub = py;
        updateConstrProp(nlp,'endeffy_sca_LR','first',arginpy);
        arginpz.lb = pz;
        arginpz.ub = pz;
        updateConstrProp(nlp,'endeffz_sca_LR','first',arginpz);
        
        arginpxe.lb = pxe;
        arginpxe.ub = pxe;
        updateConstrProp(nlp,'endeffx_sca_LR','last',arginpxe);
        arginpye.lb = pye;
        arginpye.ub = pye;        
        updateConstrProp(nlp,'endeffy_sca_LR','last',arginpye);
        arginpze.lb = pze;
        arginpze.ub = pze;
        updateConstrProp(nlp,'endeffz_sca_LR','last',arginpze);
        
        % constraining the orientations
        o_start = pose_start.orientation;
        o_end = pose_end.orientation;
        ox = o_start(1);        oy = o_start(2);        oz = o_start(3);
        oxe = o_end(1);         oye = o_end(2);         oze = o_end(3);
        
        arginox.lb = ox;
        arginox.ub = ox;
        updateConstrProp(nlp,'o_endeffx_LR','first',arginox);
        arginoy.lb = oy;
        arginoy.ub = oy;
        updateConstrProp(nlp,'o_endeffy_LR','first',arginoy);
        arginoz.lb = oz;
        arginoz.ub = oz;
        updateConstrProp(nlp,'o_endeffz_LR','first',arginoz);
        arginoxe.lb = oxe;
        arginoxe.ub = oxe;
        updateConstrProp(nlp,'o_endeffx_LR','last',arginoxe);
        arginoye.lb = oye;
        arginoye.ub = oye;
        updateConstrProp(nlp,'o_endeffy_LR','last',arginoye);
        arginoze.lb = oze;
        arginoze.ub = oze;        
        updateConstrProp(nlp,'o_endeffz_LR','last',arginoze);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Box constraints in each subregion
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        n_node = nlp.NumNode;
        p_min = Behavior.SubBehavior(i).box.p_min;
        p_max = Behavior.SubBehavior(i).box.p_max;
        
        pxmin = p_min(1);        pymin = p_min(2);        pzmin = p_min(3);
        pxmax = p_max(1);         pymax = p_max(2);         pzmax = p_max(3);
        
        arginboxpx.lb = pxmin;
        arginboxpx.ub = pxmax;
        updateConstrProp(nlp,'endeffx_sca_LR',2:n_node-1,arginboxpx);
        arginboxpy.lb = pymin;
        arginboxpy.ub = pymax;
        updateConstrProp(nlp,'endeffy_sca_LR',2:n_node-1,arginboxpy);
        arginboxpz.lb = pzmin;
        arginboxpz.ub = pzmax;
        updateConstrProp(nlp,'endeffz_sca_LR',2:n_node-1,arginboxpz);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Link the NLP problem to a NLP solver
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        solver = IpoptApplication(nlp);
        solver.Options.ipopt.max_iter = 1000;
        solver.Options.ipopt.tol = 1e-3;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Run the optimization
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if load_initial_guess
            [params,~] = loadParam(guess_file);
            [sol, info] = optimize(solver, params.sol);
        else
            [sol, info] = optimize(solver);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Export the optimization result
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [tspan, states, inputs, params] = exportSolution(nlp, sol);

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Plot the basic result
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        flow.t = tspan;
        flow.states = states;
        Analyze(flow);

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Save param in a yaml file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        param = cell(1,1);
        param{1}.name = 'FanucBurgerFlippyTrajectory';
        polydegree = flippy.VirtualConstraints.pos.PolyDegree;
        num2degree = flippy.VirtualConstraints.pos.Dimension;
        param{1}.a    = reshape(params.apos,num2degree,polydegree+1);
        if isfield(params,{'params.ppos'}), param{1}.p    = params.ppos;
        else, param{1}.p = [tspan(end), tspan(1)];end
        param{1}.v    = [];
        param{1}.x_plus = [states.x(:,1);states.dx(:,1)]';
        param{1}.x_minus = [states.x(:,end);states.dx(:,end)]';
        param{1}.sol = sol;

        if save_solution_in_file && info.status==0
           param_save_file = loadInitialGuessFile(Behavior.sub_behavior_names{i},cur,num_grid,pose_start,pose_end);
           yaml_write_file(param_save_file,param);
        end
        
        nparam = size(param{1}.a,2);
        r = [param{1}.p(1),zeros(1,nparam-1);param{1}.a];
        
        Behavior.SubBehavior(i).optimization_result = r;
%         writecsvfilebezier(param{1}.p(1),param{1}.a);
        
    end
    writecsvfile(Behavior);
end