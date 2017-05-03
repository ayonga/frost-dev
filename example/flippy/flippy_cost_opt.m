function nlp = flippy_cost_opt(nlp, bounds, varargin)
    
    
    
    plant = nlp.Plant;
    u = plant.Inputs.Control.u;
    
    u2r = tovector(norm(u).^2);
    u2r_fun = SymFunction(['torque_' plant.Name],u2r,{u});
    addRunningCost(nlp,u2r_fun,{'u'});
end