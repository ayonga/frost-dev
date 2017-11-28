function TorqueOverTime(nlp, sys)

    
    domains = sys.Gamma.Nodes.Domain;
    T  = SymVariable('t',[2, 1]);
    for i=1:numel(domains)
        domain = domains{i};
    
        u = domain.Inputs.Control.u;
        u2r = tovector(norm(u).^2)./(T(2)-T(1));
        u2r_fun = SymFunction(['torqueOverTime_' sys.Gamma.Nodes.Name{i}],u2r,{u,T});
        rs_phase = getPhaseIndex(nlp,sys.Gamma.Nodes.Name{i});
        addRunningCost(nlp.Phase(rs_phase),u2r_fun,{'u', 'T'});
        
    end
    nlp.update;
    
end
