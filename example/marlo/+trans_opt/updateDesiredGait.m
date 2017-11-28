function [nlp] = updateDesiredGait(nlp, sys, target_gait)
    domains = sys.Gamma.Nodes.Domain;
    
    
    idx = [7:9, 12:14]; 
    for j=1:numel(domains) %% HECK!!!!!!
        domain = domains{j};
        phase_idx = getPhaseIndex(nlp,sys.Gamma.Nodes.Name{j});
        for i = 1:nlp.Phase(phase_idx).NumNode
            x_star_val = target_gait(j).states.x(idx, i);
            dx_star_val = target_gait(j).states.dx(idx, i);
%             u_star_val = target_gait(j).inputs.u(:,i);
            updateCostProp(nlp.Phase(phase_idx), ['stateDeviation_', domain.Name], i, 'AuxData',...
                {{x_star_val, dx_star_val}});
        end
    end
    nlp.update();
end
