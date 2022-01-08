function nlp = imposeNLPConstraint(obj, nlp, varargin)
    % Add system dynamics equations as a set of equality constraints   
    %

    % basic information of NLP decision variables
    dim = obj.Dimension;
    
    states = obj.States;
    
    % M(x)dx or M(x)ddx
    Mmat = obj.getMassMatrix;
    Fvec = obj.getDriftVector;
    
    switch obj.Type
        case 'FirstOrder'
            dX = states.dx;
            deps = {states.x, states.dx};
            Gv = SymExpression(zeros(dim,1));
            input_names = fieldnames(obj.Inputs);
            n_input = length(input_names);
            if n_input > 0
                for i=1:n_input
                    f_name = input_names{i};
                    input = obj.Inputs.(f_name);
                    % compute the Gvec, and add it up
                    Gv = Gv + input.Gmap*input;
                    deps = [deps, {input}]; %#ok<*AGROW>
                end
            end
        case 'SecondOrder'
            dX = states.ddx;
            deps = {states.x, states.dx, states.ddx};
            Gv = SymExpression(zeros(dim,1));
            input_names = fieldnames(obj.Inputs);
            n_input = length(input_names);
            if n_input > 0
                for i=1:n_input
                    f_name = input_names{i};
                    input = obj.Inputs.(f_name);
                    % compute the Gvec, and add it up
                    Gv = Gv + input.Gmap*input;
                    deps = [deps, {input}];
                end
            end
    end
    
    
    dyn_eqn_func = SymFunction('dynamics_equation',Mmat*dX + Fvec - Gv,deps);
    
    
    deps_name = cellfun(@(x)x.Name, deps, 'UniformOutput',false);
    % add dynamical equation constraints
    nlp = addNodeConstraint(nlp,'all',dyn_eqn_func,deps_name, 0, 0);
    
end
