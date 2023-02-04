function nlp  = LoadStandingProblem(system, bounds, load_path)
    
    
    if nargin < 3
        load_path = [];
    end
    

    %     right_stance = system.Gamma.Nodes.Domain{1};
    %     right_stance.UserNlpConstraint = @opt.callback.RightStanceConstraints;% right stance
    %     left_stance = system.Gamma.Nodes.Domain{2};
    %     left_stance.UserNlpConstraint = @opt.callback.LeftStanceConstraints; % left stance
    %
    %     left_impact = system.Gamma.Edges.Guard{1};
    %     left_impact.UserNlpConstraint = @opt.callback.LeftImpactConstraints;  % left impact
    %     right_impact = system.Gamma.Edges.Guard{2};
    %     right_impact.UserNlpConstraint = @opt.callback.RightImpactConstraints; % right impact
    
    double_stance = system.Gamma.Nodes.Domain{1};
    double_stance.UserNlpConstraint =  @opt.callback.DoubleStanceConstraints;
    
    %     num_grid.RightStance = 10;
    %     num_grid.LeftStance = 10;
    num_grid.DoubleStance = 10;
    
    options = {'CollocationScheme','HermiteSimpson',...
        'EqualityConstraintBoundary', 1e-4,...
        'DistributeTimeVariable', false,...
        'DistributeParameters',false};
    
    nlp = HybridTrajectoryOptimization('atlas_opt', system, num_grid, [], options{:});
    
    if isempty(load_path)
        nlp.configure(bounds);
    else
        nlp.configure(bounds, 'LoadPath',load_path);
    end
    % cost function
    opt.cost.Torques(nlp, system);
    nlp.update;
        
        
end