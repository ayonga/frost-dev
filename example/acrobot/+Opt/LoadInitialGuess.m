function LoadInitialGuess(nlp, init_params)
    % load initial guess from previous result or simulated trajectory.
    % input can be the file name of the optimal gait or the structure of
    % exported data which should include the followings:
    % * tspan
    % * states    
    % * params
    % * inputs
    
    
    
        
    if isa(nlp,'TrajectoryOptimization')
        n_phase = 1;
        is_hybrid = false;
    elseif isa(nlp,'HybridTrajectoryOptimization')
        n_phase = length(nlp.Phase);
        is_hybrid = true;
    else
        error('Invalid NLP object.\n');
    end
    
    for i=1:n_phase
        if is_hybrid
            phase_nlp = nlp.Phase(i);            
        else
            phase_nlp = nlp;
        end
        tspan  = init_params(i).tspan;
        states = init_params(i).states;
        params = init_params(i).params;
        inputs = init_params(i).inputs;
        
        vars = phase_nlp.OptVarTable.Properties.VariableNames;
        % update time
        if ismember('T',vars)
            if phase_nlp.Options.DistributeTimeVariable
                updateVariableProp(phase_nlp, 'T','all', 'x0', [tspan(1);tspan(end)]);
            else
                updateVariableProp(phase_nlp, 'T','first', 'x0', [tspan(1);tspan(end)]);
            end
        end
        if isa(phase_nlp.Plant,'ContinuousDynamics')
            if phase_nlp.NumNode == numel(tspan) % if it has the same number of nodes
                for j=1:phase_nlp.NumNode
                    updateVariableProp(phase_nlp, 'x',j, 'x0', states.x(:,j));
                    updateVariableProp(phase_nlp, 'dx',j, 'x0', states.dx(:,j));
                    if isfield(states,'ddx')
                        updateVariableProp(phase_nlp, 'ddx',j, 'x0', states.ddx(:,j));
                    end
                    
                    if isfield(states,'s') && ismember('s', vars)
                        updateVariableProp(phase_nlp, 's',j, 'x0', states.s(:,j));
                    end
                    if isfield(states,'sDot') && ismember('sDot', vars)
                        updateVariableProp(phase_nlp, 'sDot',j, 'x0', states.sDot(:,j));
                    end
                end
                
                input_names = fieldnames(inputs);
                for k = 1:numel(input_names)
                    i_name = input_names{k};
                    if ismember(i_name,vars)
                        in = inputs.(i_name);
                        for j=1:phase_nlp.NumNode
                            updateVariableProp(phase_nlp, i_name, j, 'x0', in(:,j));
                        end
                    end
                end
                
            else % if the number of nodes changes
                x = even_sample(tspan,states.x,(phase_nlp.NumNode-1)/(tspan(end)-tspan(1)));
                dx = even_sample(tspan,states.dx,(phase_nlp.NumNode-1)/(tspan(end)-tspan(1)));
                if isfield(states,'ddx')
                    ddx = even_sample(tspan,states.ddx,(phase_nlp.NumNode-1)/(tspan(end)-tspan(1)));
                end
                for j=1:phase_nlp.NumNode
                    updateVariableProp(phase_nlp, 'x',j, 'x0', x(:,j));
                    updateVariableProp(phase_nlp, 'dx',j, 'x0', dx(:,j));
                    if isfield(states,'ddx')
                        updateVariableProp(phase_nlp, 'ddx',j, 'x0', ddx(:,j));
                    end
                end
                
                input_names = fieldnames(inputs);
                for k = 1:numel(input_names)
                    i_name = input_names{k};
                    if ismember(i_name,vars)
                        in = even_sample(tspan,inputs.(i_name),(phase_nlp.NumNode-1)/(tspan(end)-tspan(1)));
                        for j=1:phase_nlp.NumNode
                            updateVariableProp(phase_nlp, i_name, j, 'x0', in(:,j));
                        end
                    end
                end
                
            end
        elseif isa(phase_nlp.Plant,'DiscreteDynamics')
            updateVariableProp(phase_nlp, 'x', 'first', 'x0', states.x);
            updateVariableProp(phase_nlp, 'xn', 'first', 'x0', states.xn);
            if isfield(states,'dx')
                updateVariableProp(phase_nlp, 'dx', 'first', 'x0', states.dx);
                updateVariableProp(phase_nlp, 'dxn', 'first', 'x0', states.dxn);
            end
            input_names = fieldnames(inputs);
            for k = 1:numel(input_names)
                i_name = input_names{k};
                if ismember(i_name,vars)
                    in = inputs.(i_name);
                    updateVariableProp(phase_nlp, i_name, 'first', 'x0', in);
                    
                end
            end
        end
        
        param_names = fieldnames(params);
        for k = 1:numel(param_names)
            p_name = param_names{k};
            if ismember(p_name,vars)
                p = params.(p_name);
                if phase_nlp.Options.DistributeParameters
                    updateVariableProp(phase_nlp, p_name, 'all', 'x0', p);
                else
                    updateVariableProp(phase_nlp, p_name, 'first', 'x0', p);
                end
            end
        end
    end
    
    
    
    nlp.update();
    
end