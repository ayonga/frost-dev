function nlp  = LoadProblem(system, bounds, load_path)
    
    
    if nargin < 3
        load_path = [];
    end
    

    num_grid.RightStance = 10;
    num_grid.LeftStance = 10;
    
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
    opt.cost.Power(nlp, system);
    nlp.update;
        
        
end