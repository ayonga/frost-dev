function nlp = VelocityCost(nlp, varargin)
    
    
    W  = varargin{1};
    
    
    
    plant = nlp.Plant;
    dq = plant.States.dx;
    ndof = nlp.Plant.numState;
    Ws  = SymVariable('w',[ndof,ndof]);
    
    vel = (dq).'*Ws*(dq);
    vel_fun = SymFunction(['vel_cost_' plant.Name],vel,{dq},{SymVariable(Ws(:))});
    addRunningCost(nlp,vel_fun,{'dx'},{W(:)});
end