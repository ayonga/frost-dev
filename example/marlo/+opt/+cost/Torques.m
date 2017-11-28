function Torques(nlp, sys)
    
    domains = sys.Gamma.Nodes.Domain;
    
    for i=1:numel(domains)
        domain = domains{i};
    
        u = domain.Inputs.Control.u;
        u2r = tovector(norm(u).^2);
        u2r_fun = SymFunction(['torque_' sys.Gamma.Nodes.Name{i}],u2r,{u});
        rs_phase = getPhaseIndex(nlp,sys.Gamma.Nodes.Name{i});
        addRunningCost(nlp.Phase(rs_phase),u2r_fun,{'u'});
        
    end
    nlp.update;
end
