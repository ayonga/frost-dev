function [Behavior] = pickup_and_drop_burger_behavior(flippy,cur,varargin)
%% some constants - should be made part of flippy grill properties in future
pose_home = getHomePose();
p_home = pose_home.position;
o_home = pose_home.orientation;

% grill and table specifications : in future all this should be in a different struct
boxes = getGrillAndTableSpecs();

%% assign p_start and p_end after satisfying a set of conditions provided below
numargin = numel(varargin);
if numargin < 1
    error('No starting or ending position provided. Nothing to do.');
elseif numargin < 3
    warning(['No starting position provided. Setting [',num2str(p_home),'] as the starting position']);
    p_start = p_home;
    o_start = o_home;
    burger_index = 1;
    drop_index = 2;
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
    burger_index = 2;
    drop_index = 3;
end

if isfield(varargin{burger_index},'position')
    p_burger = varargin{burger_index}.position;
else
    error('Burger position field not provided');
end
if isfield(varargin{burger_index},'orientation')
    o_burger = varargin{burger_index}.orientation;
else
    o_burger = [0,0,0];
end

if isfield(varargin{drop_index},'position')
    p_drop = varargin{drop_index}.position;
else
    error('Burger position field not provided');
end
if isfield(varargin{drop_index},'orientation')
    o_drop = varargin{drop_index}.orientation;
else
    o_drop = [0,0,0];
end
    
if p_burger < boxes.grill_box.p_min(3)
    error('Z pos of burger location is below the grill height');
end

if p_drop < boxes.table_box.p_min(3)
    error('Z pos of drop location is below the table height');
end
        
pose_start.position = p_start;
pose_start.orientation = o_start;
pose_burger.position = p_burger;
pose_burger.orientation = o_burger;
pose_drop.position = p_drop;
pose_drop.orientation = o_drop;

%% this defines the behavior and the subbehavior for picking up and drop the burger on the table
Behavior = struct();

Behavior = validatePickAndDropBehaviorBox(Behavior, boxes, pose_home, pose_start, pose_burger, pose_drop);


%% The main script to run the burger behavior optimization

load_initial_guess = true; % not sure if this should allowed
if load_initial_guess
    disp('Load initial guess enabled');
end
save_solution_in_file = true; % disable saving of solutions, but it gets modified later on
if save_solution_in_file
    disp('Save new solution in file enabled.');
end


%% optimization code is here
nSubBehaviors = Behavior.nSubBehaviors;
disp(['Number of subbehaviors: ',num2str(nSubBehaviors)]);
num_grid = 10;
        
    for i=1:nSubBehaviors
       
        sub_behavior = Behavior.SubBehavior(i);
        sub_behavior_name = Behavior.sub_behavior_names{i};
        
        % get the bounds
        bounds = getBounds(flippy,sub_behavior_name);

        fanuc_constr_opt_str = 'commonConstraints';
        flippy.UserNlpConstraint = str2func(fanuc_constr_opt_str);

        disp(['Optimizing the subbehavior: ',Behavior.SubBehavior(i).description]);
        
        [guess_file, solution_in_file, save_file] = ...
            findNearestGuessFile(cur,num_grid,sub_behavior);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Create a gait-optimization NLP based on the existing hybrid system
        %%%% model. 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        opts = struct(...%'ConstantTimeHorizon',nan(2,1),... %NaN - variable time, ~NaN, fixed time
            'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
            'EqualityConstraintBoundary',0,...
            'DistributeTimeVariable',false); % non-zero positive small value will relax the equality constraints
        nlp = TrajectoryOptimization('fanucopt', flippy, num_grid, bounds, opts);

        nlp = configureFlippyConstraints(nlp,bounds,sub_behavior);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Link the NLP problem to a NLP solver
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        solver = IpoptApplication(nlp);
        solver.Options.ipopt.max_iter = 3000;
        solver.Options.ipopt.tol = 1e-3;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Run the optimization
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if load_initial_guess && ~isempty(guess_file)
            [params,~] = loadParam(guess_file);
            [sol, info] = optimize(solver, params.sol);
        else
            [sol, info] = optimize(solver);
        end
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Export and Plot the trajectory %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        flow = plotSubBehavior(nlp,sol);
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Save param in a yaml file and also update qend (end point of trajectory %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if i >= nSubBehaviors
            next_ind = 1;
        else
            next_ind = i+1;
        end
        [Behavior.SubBehavior(i).optimization_result, ...
            states_from_prev_trajectory,...
            pose_start_prev_trajectory,...
            pose_end_prev_trajectory] = ...
            saveSubBehaviorYamlFile(flow,info,save_file,save_solution_in_file,solution_in_file);
        
        % end points from previous trajectory must match with starting
        % points of next trajectory
        if isempty(Behavior.SubBehavior(next_ind).qstart)
            Behavior.SubBehavior(next_ind).qstart = states_from_prev_trajectory.q_end;
            Behavior.SubBehavior(next_ind).qend = states_from_prev_trajectory.q_start;
            Behavior.SubBehavior(next_ind).dqstart = states_from_prev_trajectory.dq_end;
            Behavior.SubBehavior(next_ind).dqend = states_from_prev_trajectory.dq_start;
        end
        if isempty(Behavior.SubBehavior(next_ind).pose_start)
            Behavior.SubBehavior(next_ind).pose_start.position = pose_end_prev_trajectory.position;
            Behavior.SubBehavior(next_ind).pose_end.position = pose_start_prev_trajectory.position;
        end
        
    end
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% write the basic result in a csv file for testing in the robot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    writecsvfile(Behavior);
end