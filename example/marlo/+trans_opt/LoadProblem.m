function nlp  = LoadProblem(system, bounds, gait, load_path)
    
    
    if nargin < 4
        load_path = [];
    end
    

    num_grid.RightStance1 = 10;
    num_grid.LeftStance1 = 10;
    num_grid.RightStance2 = 10;
    num_grid.LeftStance2 = 10;
    
    options = {'EqualityConstraintBoundary', 1e-4,...
        'DistributeTimeVariable', false,...
        'DistributeParameters',false};
    
    nlp = HybridTrajectoryOptimization('atrias_opt', system, num_grid, [], options{:});
    
    if isempty(load_path)
        nlp.configure(bounds);
    else
        nlp.configure(bounds, 'LoadPath',load_path);
    end
    % cost function
    %     opt.cost.Power(nlp, system);
    trans_opt.cost.StateDeviation(nlp, system, gait);
    nlp.update;
        
        
end