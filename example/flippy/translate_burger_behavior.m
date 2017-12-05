function [Behavior] = translate_burger_behavior(flippy,cur,varargin)
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
elseif numargin < 2
    warning(['No starting position provided. Setting [',num2str(p_home),'] as the starting position']);
    p_start = p_home;
    o_start = o_home;
    end_index = 1;
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
    end_index = 2;
end

if isfield(varargin{end_index},'position')
    p_end = varargin{end_index}.position;
else
    error('Ending position field not provided');
end
if isfield(varargin{end_index},'orientation')
    o_end = varargin{end_index}.orientation;
else
    o_end = [0,0,0];
end

pose_start.position = p_start;
pose_start.orientation = o_start;
pose_end.position = p_end;
pose_end.orientation = o_end;

%% this defines the behavior and the subbehavior for translating burgurs from p_start to p_end
Behavior = struct();

Behavior = validateTranslateBehaviorBox(Behavior, boxes, pose_home, pose_start, pose_end);


%% The main script to run the burger behavior optimization

load_initial_guess = true; % not sure if this should allowed
if load_initial_guess
    disp('Load initial guess enabled.');
end
save_solution_in_file = true; % disable saving of solutions, but it gets modified later on
if save_solution_in_file
    disp('Save new solution in file enabled.');
end


%% optimization code is here
nSubBehaviors = Behavior.nSubBehaviors;
disp(['Total number of subbehaviors: ',num2str(nSubBehaviors)]);
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
        solver.Options.ipopt.max_iter = 5000;
        solver.Options.ipopt.tol = 1e-3;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Run the optimization
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if load_initial_guess && ~isempty(guess_file)
            [params,~] = loadParam(guess_file);
            [dimVars, ~,~] = getVarInfo(nlp);
            if size(params.sol,1) == dimVars
                x0 = params.sol;
            else
                warning('Initial guess file not used. Incorrect number of variables');
                x0 = [];
            end
        else
            x0 = [];
        end

        if isempty(x0)
            [sol, info] = optimize(solver);
        else
            [sol, info] = optimize(solver, x0);
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
        [Behavior.SubBehavior(i).optimization_result, ...
            ~,~,~] = ...
            saveSubBehaviorYamlFile(flow,info,save_file,save_solution_in_file,solution_in_file);
        
    end
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% write the basic result in a csv file for testing in the robot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    writecsvfile(Behavior);
end