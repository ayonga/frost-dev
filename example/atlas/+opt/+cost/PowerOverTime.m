function PowerOverTime(nlp, sys)
    
    domains = sys.Gamma.Nodes.Domain;
    T  = SymVariable('t',[2, 1]);
    for i=1:numel(domains)
        domain = domains{i};
    
        u = domain.Inputs.Control.u;
        dq = domain.States.dx;
        B = domain.Gmap.Control.u;
        
        
        P = tovector(norm(dq.*(B*u)).^2)./(T(2)-T(1));
        power_fun = SymFunction(['powerOverTime_' sys.Gamma.Nodes.Name{i}],P,{T,u,dq});
        rs_phase = getPhaseIndex(nlp,sys.Gamma.Nodes.Name{i});
        addRunningCost(nlp.Phase(rs_phase),power_fun,{'T','u','dx'});
        
    end
    nlp.update;
end