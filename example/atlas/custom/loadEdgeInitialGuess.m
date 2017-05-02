function nlp = loadEdgeInitialGuess(nlp, src, tar)
    % load initial guess from a simulated results
    src_calcs = src.Flow;
    tar_calcs = tar.Flow;
    
    plant = nlp.Plant;
    
    
    [x_minus, lambda] = calcDiscreteMap(plant,src_calcs.t(end),[src_calcs.x(:,end);src_calcs.dx(:,end)]);
    
    nlp = updateVariableProp(nlp, 'x', 'all', 'x0',src_calcs.x(:,end));
    nlp = updateVariableProp(nlp, 'dx', 'all', 'x0',src_calcs.dx(:,end));
    nlp = updateVariableProp(nlp, 'xn', 'all', 'x0',tar_calcs.x(:,1));
    nlp = updateVariableProp(nlp, 'dxn', 'all', 'x0',tar_calcs.dx(:,1));
    input = fieldnames(lambda);
    for k=1:numel(input)
        nlp = updateVariableProp(nlp, input{k},  'all', 'x0',lambda.(input{k}));
    end
    %     nlp = updateVariableProp(nlp, 'fqfixed', 'all', 'x0',lambda.fqfixed);
    %     nlp = updateVariableProp(nlp, 'fLeftSole', 'all', 'x0',lambda.fLeftSole);
end