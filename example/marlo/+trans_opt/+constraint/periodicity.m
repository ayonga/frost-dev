function periodicity( nlp, node, bounds )
    %PERIODICITY Summary of this function goes here
    %   Detailed explanation goes here
    domain = nlp.Plant;
    x = domain.States.x;
    dx = domain.States.dx;
    idx = [7:9, 12:14]; 
    
    
    fs = [1; dx(1); dx(2)];
    
    q_fit = SymVariable('p',[length(idx),3]);
    dq_fit = SymVariable('dp',[length(idx),3]);
    
    P = bounds.midState_QFit;
    dP = bounds.midState_dQFit;
    
    
    constraint = [q_fit*fs - x(idx); dq_fit*fs - dx(idx)];
    lb = -0.002;
    ub = 0.002;
    constraint_func = SymFunction(['periodicState_',domain.Name], constraint, {x, dx}, {q_fit, dq_fit});
    addNodeConstraint(nlp, constraint_func, {'x', 'dx'}, node, lb, ub, 'NonLinear',{P,dP});
end

