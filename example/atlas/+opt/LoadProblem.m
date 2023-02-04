function nlp  = LoadProblem(system, bounds, load_path)
    
    
    if nargin < 3
        load_path = [];
    end
    

    num_grid.RightStance = 15;
    num_grid.LeftStance = 15;
    
    options = {'CollocationScheme','HermiteSimpson',...
        'EqualityConstraintBoundary', 1e-4,...
        'DistributeTimeVariable', false,...
        'StackVariable',true,...
        'DistributeParameters',false,...
        'LoadPath',load_path};
    
    nlp = HybridTrajectoryOptimization('atlas_opt', system, num_grid, bounds, options{:});
    
    
    % cost function
    opt.cost.Torques(nlp, system);
    nlp.update;
        
        
end