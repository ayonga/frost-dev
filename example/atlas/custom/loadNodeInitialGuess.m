function nlp = loadNodeInitialGuess(nlp, plant, param)
    % load initial guess from a simulated results
    calcs = plant.Flow;
    n_node = nlp.NumNode;
    [~,qe]  = even_sample(calcs.t,calcs.x,(n_node-1)/(calcs.t(end)-calcs.t(1)));
    [~,dqe]  = even_sample(calcs.t,calcs.dx,(n_node-1)/(calcs.t(end)-calcs.t(1)));
    [~,ddqe]  = even_sample(calcs.t,calcs.ddx,(n_node-1)/(calcs.t(end)-calcs.t(1)));
    [~,u]  = even_sample(calcs.t,calcs.u,(n_node-1)/(calcs.t(end)-calcs.t(1)));
    input = fieldnames(calcs.lambda);
    for i=1:numel(input)
        [~,lambda.(input{i})]  = even_sample(calcs.t,[calcs.lambda.(input{i})],(n_node-1)/(calcs.t(end)-calcs.t(1)));
        % [~,lambda.(input{i})]  = even_sample(calcs.t,[calcs.lambda.(input{i})],(n_node-1)/(calcs.t(end)-calcs.t(1)));
    end
    cstr = fieldnames(plant.HolonomicConstraints);
    for i=1:numel(cstr)
        h.(cstr{i}) = plant.HolonomicConstraints.(cstr{i}).calcConstraint(calcs.x(:,1));
    end
    
    
    
    nlp = updateVariableProp(nlp, 'T','all', 'x0', [calcs.t(1);calcs.t(end)]);
    for i=1:n_node
        nlp = updateVariableProp(nlp, 'x',  i, 'x0',qe(:,i));
        nlp = updateVariableProp(nlp, 'dx',  i, 'x0',dqe(:,i));
        nlp = updateVariableProp(nlp, 'ddx',  i, 'x0',ddqe(:,i));
        nlp = updateVariableProp(nlp, 'u',  i, 'x0',u(:,i));
        for k=1:numel(input)
            nlp = updateVariableProp(nlp, input{k},  i, 'x0',lambda.(input{k})(:,i));
        end
    end
    cstr = fieldnames(plant.HolonomicConstraints);
    for i=1:numel(cstr)
        nlp = updateVariableProp(nlp, ['p' cstr{i}], 'all', 'x0',h.(cstr{i}));
    end
    nlp = updateVariableProp(nlp, 'avelocity', 'all', 'x0',param.avelocity(:));
    nlp = updateVariableProp(nlp, 'pvelocity', 'all', 'x0',param.pvelocity(:));
    nlp = updateVariableProp(nlp, 'aposition', 'all', 'x0',param.aposition(:));
    nlp = updateVariableProp(nlp, 'pposition', 'all', 'x0',param.pposition(:));
end