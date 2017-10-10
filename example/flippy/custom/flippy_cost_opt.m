function nlp = flippy_cost_opt(nlp, bounds, varargin)
     
    nw = 28;
    w = SymVariable('w',[nw,1]);
    sumw = transpose(sin(pi*w))*sin(pi*w);

    
    plant = nlp.Plant;
    u = plant.Inputs.Control.u;
    
    u2r = tovector(norm(u).^2);
    u2rw =  tovector(norm(u).^2) + 1000*sumw;
    u2r_fun = SymFunction(['torque_' plant.Name],u2r,{u});
%     u2r_fun = SymFunction(['torque_w_' plant.Name],u2rw,{u,w});
%     addRunningCost(nlp,u2r_fun,{'u','w'});
    addRunningCost(nlp,u2r_fun,{'u'});
end