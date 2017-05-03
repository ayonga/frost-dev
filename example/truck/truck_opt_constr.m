function nlp = truck_opt_constr(nlp, bounds, varargin)
    % add custom NLP constraints
    
    sys = nlp.Plant;
    x = sys.States.x;
    dx = sys.States.dx;
    
    % virtual constraints
    kp = bounds.kp;
    kd = bounds.kd;
    imposeNLPConstraint(sys.VirtualConstraints.y, nlp, [kp,kd], [1,1]);
    
    
    % ymax constraints
    y_max = sys.Params.ymax;
    ymax_cstr_fn = SymFunction('ymax',[y_max - x(3); y_max + x(3)],{x,y_max});
    nlp = addNodeConstraint(nlp, ymax_cstr_fn, {'x','ymax'}, 'all', 0, 10, 'Linear');
    
    
    % barrier B(x) = 1-(x-x_des)' Pb (x-x_des); Bdot(x) = 2(x-x_des)' Pb dx
    rd = bounds.rd;
    x_des_val = sys.x_des(rd);
    x_d = SymVariable('xd',[8,1]);
    load('barrier.mat','P_bar');
    P_bar_aug = blkdiag(zeros(2),P_bar([1 2 3 4 6 5],[1 2 3 4 6 5]));
    %     bar = 1-transpose(x-x_des_val) * P_bar_aug * (x-x_des_val);
    %     bar_dot = - 2 * transpose(x-x_des_val) * P_bar_aug * dx;
    bar = 1-transpose(x) * P_bar_aug * x;
    bar_dot = - 2 * transpose(x) * P_bar_aug * dx;
    
    bar_cond = SymFunction('bar_cond',bar_dot + (1-exp(-bar))/(1+exp(-bar)),{x,dx},{x_d});
    nlp = addNodeConstraint(nlp, bar_cond, {'x','dx'}, 'all', 0, inf, 'Nonlinear',x_des_val);
    
    
    a=sys.Params.ay;
    alpha_cond1 = SymFunction('alpha_cond',a(1).^2*.5+0.5-a(end).^2,{a});
    nlp = addNodeConstraint(nlp, alpha_cond1, {'ay'}, 'all', 0, inf, 'Nonlinear');
    
    alpha_cond2 = SymFunction('alpha_cond',a(end),{a});
    nlp = addNodeConstraint(nlp, alpha_cond2, {'ay'}, 'all', -0.1, 0.1, 'Linear');
end