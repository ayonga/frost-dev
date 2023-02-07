function [gait, sol, info, total_time] = solve(nlp, x0, info)
    
    % Link the NLP problem to a NLP solver
    solver = IpoptApplication(nlp);
    solver.Options.ipopt.hessian_approximation = 'limited-memory';
    solver.Options.ipopt.bound_frac = 1e-8;
    solver.Options.ipopt.bound_push = 1e-8;
    % Possible parameter changes to solver
    solver.Options.ipopt.tol = 1e-2;
    solver.Options.ipopt.dual_inf_tol = 1e-2;
    solver.Options.ipopt.constr_viol_tol = 1e-5;
    solver.Options.ipopt.compl_inf_tol = 1e-2;
    solver.Options.ipopt.max_iter = 10000;
    solver.Options.ipopt.linear_solver = 'ma57';
    %%% Only use this if contraints are the same
    if nargin > 2
        solver.Options.ipopt.point_perturbation_radius = 0;
        solver.Options.ipopt.warm_start_bound_push = 1e-8;
        solver.Options.ipopt.warm_start_mult_bound_push = 1e-8;
        solver.Options.ipopt.mu_init = 1e-6;
        solver.Options.ipopt.warm_start_init_point = 'yes';
        solver.Options.zl = info.zl;
        solver.Options.zu = info.zu;
        solver.Options.lambda = info.lambda;
    end
    
    %     solver.Options.ipopt.print_timing_statistics = 'yes';
    %     solver.Options.ipopt.print_level = 10;
%     solver.Options.ipopt.nlp_lower_bound_inf = -1e6;
%     solver.Options.ipopt.nlp_upper_bound_inf = 1e6;
    %     solver.Options.ipopt.acceptable_tol = 1e-2;
    %     solver.Options.ipopt.acceptable_constr_viol_tol = 1e-4;
    %     solver.Options.ipopt.acceptable_dual_inf_tol = 1e-2;
    %     solver.Options.ipopt.acceptable_compl_inf_tol = 1e-2;
    %     solver.Options.ipopt.print_user_options = 'yes';
    % Run the optimization
    start_time = tic();
    if nargin < 2
        [sol, info] = optimize(solver);
    else
        [sol, info] = optimize(solver, x0);
    end
    
    %     tspan{3} = tspan{1}(end) + tspan{3};
    total_time = toc(start_time);
    gait = opt.parse(nlp, sol);
    
    
    
        
end