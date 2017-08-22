function nlp = ZMPCost(nlp, varargin)
    
    
    w = varargin{1};
    
    
    plant = nlp.Plant;
    force = plant.Inputs.ConstraintWrench.ffoot;
    
    ws = SymVariable('w');
    
    zmp = -force(3)./force(2);
    constr = ws*(zmp+0.1).^2;
    m_fun = SymFunction(['zmp_cost_' plant.Name],tovector(constr),{force},{ws});
    addRunningCost(nlp,m_fun,{'ffoot'},{w});
end