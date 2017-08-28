function [nlp, bounds] = UpdateBounds(nlp, sys, bounds)

    %% update variable bounds
    if nargin < 3
        bounds = Opt.GetBounds(sys);
    end
    nlp.updateVariableBounds(bounds);

    if isa(nlp,'TrajectoryOptimization')
        
        sys.UserNlpConstraint(nlp,bounds);
    elseif isa(nlp,'HybridTrajectoryOptimization')
        n_phase = length(nlp.Phase);
        for i=1:n_phase
            plant = nlp.Phase(i).Plant;
            
            name = nlp.Phase(i).Name;
            phase_bounds = bounds.(name);
            
            plant.UserNlpConstraint(nlp.Phase(i),phase_bounds);
        end
    else
        error('Invalid NLP object.\n');
    end

    nlp = Opt.AddCost(nlp,sys,bounds);
    %% update
    nlp.update;

end