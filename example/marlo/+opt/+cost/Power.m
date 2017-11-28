function Power(nlp, sys)
    
    domains = sys.Gamma.Nodes.Domain;
    
    for i=1:numel(domains)
        domain = domains{i};
    
        u = domain.Inputs.Control.u;
        dq = domain.States.dx;
        B = domain.Gmap.Control.u;
        
        
        P = tovector(norm(dq.*(B*u)).^2);
        power_fun = SymFunction(['power_' sys.Gamma.Nodes.Name{i}],P,{u,dq});
        rs_phase = getPhaseIndex(nlp,sys.Gamma.Nodes.Name{i});
        addRunningCost(nlp.Phase(rs_phase),power_fun,{'u','dx'});
        
    end
    nlp.update;
end
