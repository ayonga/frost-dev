function [gait] = parse(nlp, sol)
    %% parse the optimization results to more readible structure data
    
    [tspan, states, inputs, params] = exportSolution(nlp, sol);


    
    
    gait = struct(...
        'tspan', tspan,...
        'states', states,...
        'inputs', inputs,...
        'params', params);


end

