function nlp = truck_opt_cost(nlp, bounds, varargin)
    % add custom cost function
    sys = nlp.Plant;
    x = sys.States.x;
    dx = sys.States.dx;
    
    % 1. target states: 200*(x_f-x_des)'*P1*(x_f-x_des)
    rd = bounds.rd;
    x_des_val = sys.x_des(rd);
    x_f   = sys.States.x;
    x_d = SymVariable('xd',[8,1]);
    
    Q = diag([6 1 10 1 10 1]);
    R = 100;
    P1 = sys.pcare(Q,R);
    tar_pos = 100*(x_f-x_d).'*P1*(x_f-x_d);
    
    tar_pos_fn = SymFunction('target_pos',tar_pos,{x_f},{x_d});
    nlp = addNodeCost(nlp, tar_pos_fn, 'x', 'last', x_des_val');
    
    
    % 2. square intgeral of ddy and y
    ya = sys.VirtualConstraints.y.ActualFuncs;
    ya2 = ya{1};
    Dya2 = ya{3};
    ddya2 = Dya2*dx;
    
    
    yd2_square = SymFunction('yd2_square',tovector(500*ya2.^2),{x});
    nlp = addRunningCost(nlp, yd2_square, {'x'});
    
    ddyd2_square = SymFunction('ddyd2_square',tovector(0.1*ddya2.^2),{x,dx});
    nlp = addRunningCost(nlp, ddyd2_square, {'x','dx'});
    
    alpha_last = SymFunction('alpha_last',tovector(100*ya2.^2),{x});
    nlp = addNodeCost(nlp, alpha_last, {'x'},'last');
    
    
    % 6. norm(y) -> y[1]^2 + y[2]^2 + ... + y[n]^2 (remove the sqrt operator)
    y_squre = SymFunction('y_square',tovector(0.1*x(3).^2),{x});
    nlp = addNodeCost(nlp, y_squre, 'x', 'all');
    
    % 7. var(u) @todo how to compute the mean value
    
    % 8. max(abs(y))
    y_max = sys.Params.ymax;
    ymax_cost_fn = SymFunction('ymax_cost',tovector(20*y_max),{y_max});
    nlp = addNodeCost(nlp, ymax_cost_fn, 'ymax', 'first');
end