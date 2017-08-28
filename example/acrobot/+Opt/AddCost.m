function nlp = AddCost(nlp, sys, bounds)
    
    if isa(nlp,'TrajectoryOptimization')
        
        %         CostFcns.AngularMomentumCost(nlp);
        %         CostFcns.PositionCost(nlp, bounds.pos_weight, bounds.restPos);
        %         CostFcns.VelocityCost(nlp, bounds.vel_weight);
        CostFcns.TorqueCost(nlp, bounds.tor_weight);
        
    elseif isa(nlp,'HybridTrajectoryOptimization')
        nDomain = height(sys.Gamma.Nodes);
        for i=1:nDomain
            name = sys.Gamma.Nodes.Name{i};
            domain_bounds = bounds.(name);
            idx = getPhaseIndex(nlp, name);
            %             CostFcns.AngularMomentumCost(nlp.Phase(idx), domain_bounds.momentum_weight);
            CostFcns.PositionCost(nlp.Phase(idx), domain_bounds.pos_weight, domain_bounds.restPos);
            CostFcns.VelocityCost(nlp.Phase(idx), domain_bounds.vel_weight);
%             CostFcns.TorqueCost(nlp.Phase(idx), domain_bounds.tor_weight);
%             CostFcns.ZMPCost(nlp.Phase(idx), domain_bounds.zmp_weight);
        end
        
    else
        error('Invalid NLP object.\n');
    end
    nlp.update;
end