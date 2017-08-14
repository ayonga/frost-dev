function [gait, info, sol, solver] = SolveProblem(nlp)
    
    nlp.update();

    solver = IpoptApplication(nlp);
    solver.Options.ipopt.max_iter = 300;
    
    
    [sol, info] = optimize(solver);
    
    
    [tspan, states, inputs, params] = exportSolution(nlp, sol);
    %     gait.tspan = tspan;
    %     gait.states = states;
    %     gait.inputs = inputs;
    %     gait.params = params;

    gait = struct(...
        'tspan', tspan,...
        'states', states,...
        'inputs', inputs,...
        'params', params);
end