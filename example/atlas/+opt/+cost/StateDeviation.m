function StateDeviation(nlp, sys, gait)
    domains = sys.Gamma.Nodes.Domain;
    
    target_gait = [gait(1), gait(3)];
    
    weight = ones(1,2);%[2,4];
    idx = 10:21; % non-zero robot joints 
    for j=1:numel(domains)
        domain = domains{j};
    
        x = domain.States.x;
        dx = domain.States.dx;
        u = domain.Inputs.Control.u;
        x_star  = SymVariable('xStar', [6, 1]);
        dx_star  = SymVariable('dxStar', [6, 1]);
        u_star = SymVariable('uStar', [6,1]);
        
        
        x_delta = x(idx)- x_star;
        dx_delta = dx(idx)- dx_star;
        u_delta = u - u_star;
        cost = tomatrix(weight(j).*((x_delta.'*x_delta) + (dx_delta.'*dx_delta) + (u_delta.'*u_delta)));
        cost_func = SymFunction(['stateDeviation_', domain.Name], cost, {x, dx, u}, {x_star, dx_star, u_star});
        
        phase_idx = getPhaseIndex(nlp,sys.Gamma.Nodes.Name{j});
        for i = 1:nlp.Phase(phase_idx).NumNode
            x_star_val = target_gait(j).states.x(idx, i);
            dx_star_val = target_gait(j).states.dx(idx, i);
            u_star_val = target_gait(j).inputs.u(:,i);
            addNodeCost(nlp.Phase(phase_idx), cost_func, {'x', 'dx', 'u'}, i, {x_star_val, dx_star_val, u_star_val});
        end
    end
    
    nlp.update;
end
