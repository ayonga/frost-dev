function nlp = loadEdgeInitialGuess(nlp, src, tar)
    % load initial guess from a simulated results
    src_calcs = src.flow;
    tar_calcs = tar.flow;
    
    plant = nlp.Plant;
    
    
    [t_n, x_minus, lambda] = calcDiscreteMap(plant,src_calcs.t(end),[src_calcs.states.x(:,end);src_calcs.states.dx(:,end)]);
    
    nlp = updateVariableProp(nlp, 'x', 'all', 'x0',src_calcs.states.x(:,end));
    nlp = updateVariableProp(nlp, 'dx', 'all', 'x0',src_calcs.states.dx(:,end));
    nlp = updateVariableProp(nlp, 'xn', 'all', 'x0',tar_calcs.states.x(:,1));
    nlp = updateVariableProp(nlp, 'dxn', 'all', 'x0',tar_calcs.states.dx(:,1));
    input = fieldnames(lambda);
    for k=1:numel(input)
        nlp = updateVariableProp(nlp, input{k},  'all', 'x0',lambda.(input{k}));
    end
    %     nlp = updateVariableProp(nlp, 'fqfixed', 'all', 'x0',lambda.fqfixed);
    %     nlp = updateVariableProp(nlp, 'fLeftSole', 'all', 'x0',lambda.fLeftSole);
end