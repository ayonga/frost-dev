function nlp = AngularMomentumCost(nlp, varargin)
    
    
    w = varargin{1};
    
    
    plant = nlp.Plant;
    D = plant.Mmat;
    q = plant.States.x;
    dq = plant.States.dx;
    h_t = D(4,:)*dq;
    ws = SymVariable('w');
    %     ndof = nlp.Plant.numState;
    %     q0s = SymVariable('q0',[ndof,1]);
    %     Ws  = SymVariable('w',[ndof,ndof]);
    
    %     pos = (q-q0s).'*Ws*(q-q0s);
    m_fun = SymFunction(['momentum_cost_' plant.Name],tovector(ws*(h_t.^2)),{q,dq},{ws});
    addRunningCost(nlp,m_fun,{'x','dx'},{w});
end