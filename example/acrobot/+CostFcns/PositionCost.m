function nlp = PositionCost(nlp, varargin)
    
    q0 = varargin{2};
    W  = varargin{1};
    
    
    
    plant = nlp.Plant;
    q = plant.States.x;
    ndof = nlp.Plant.numState;
    q0s = SymVariable('q0',[ndof,1]);
    Ws  = SymVariable('w',[ndof,ndof]);
    
    pos = (q-q0s).'*Ws*(q-q0s);
    pos_fun = SymFunction(['pos_cost_' plant.Name],pos,{q},{q0s,SymVariable(Ws(:))});
    addRunningCost(nlp,pos_fun,{'x'},{q0,W(:)});
end