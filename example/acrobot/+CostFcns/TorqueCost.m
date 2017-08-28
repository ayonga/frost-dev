function nlp = TorqueCost(nlp, varargin)
    
    W  = varargin{1};
    
    
    
    plant = nlp.Plant;
    u = plant.Inputs.Control.u;
    [nu,~] = size(u);
    Ws  = SymVariable('w',[nu,nu]);
    
    torque = (u).'*Ws*(u);
    torque_fun = SymFunction(['torque_cost_' plant.Name],torque,{u},{SymVariable(Ws(:))});
    addRunningCost(nlp,torque_fun,{'u'},{W(:)});
    
    
end