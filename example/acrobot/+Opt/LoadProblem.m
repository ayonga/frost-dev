function nlp = LoadProblem(sys)
    
    opts = struct(...%'ConstantTimeHorizon',nan(2,1),... %NaN - variable time, ~NaN, fixed time
        'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
        'EqualityConstraintBoundary',1e-5,...
        'DistributeTimeVariable',true); % non-zero positive small value will relax the equality constraints
    bounds = Opt.GetBounds(sys);
    
    
    if isa(sys,'HybridSystem')
        nDomain = height(sys.Gamma.Nodes);
        num_grid = struct();
        for i=1:nDomain
            num_grid.(sys.Gamma.Nodes.Name{i}) = 10;
        end
        nlp = HybridTrajectoryOptimization('acrobotOpt', sys, num_grid, bounds, opts);
        
        
    else
        
        
        num_grid = 10;
        nlp = TrajectoryOptimization('acrobotOpt', sys, num_grid, bounds, opts);
    end
    
    nlp = Opt.AddCost(nlp,sys,bounds);
end