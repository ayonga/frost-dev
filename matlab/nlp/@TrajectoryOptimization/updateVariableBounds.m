function obj = updateVariableBounds(obj, bounds)
    % This function updates the boundary conditions of the optimization
    % variable by updating corresponding NLP variables
    %
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    
    
    % validate the input argument
    validateattributes(bounds,{'struct'},{},...
        'TrajectoryOptimization','bounds');
            
            
    %% update NLP decision variables
    if any(isnan(obj.Options.ConstantTimeHorizon)) && obj.NumNode ~= 1
        % add time as decision variables if the problem does not
        % use constant time horizon
        if isfield(bounds,'time')
            t_var.lb = zeros(2,1);
            t_var.ub = ones(2,1);
            t_var.x0 = [0;1];
            if isfield(bounds.time, 't0')
                if isfield(bounds.time.t0,'lb')
                    t_var.lb(1) = bounds.time.t0.lb;
                end
                if isfield(bounds.time.t0,'ub')
                    t_var.ub(1) = bounds.time.t0.ub;
                end
                if isfield(bounds.time.t0,'x0')
                    t_var.x0(1) = bounds.time.t0.x0;
                end
            end
            
            if isfield(bounds.time, 'tf')
                if isfield(bounds.time.tf,'lb')
                    t_var.lb(2) = bounds.time.tf.lb;
                end
                if isfield(bounds.time.tf,'ub')
                    t_var.ub(2) = bounds.time.tf.ub;
                end
                if isfield(bounds.time.tf,'x0')
                    t_var.x0(2) = bounds.time.tf.x0;
                end
            end
            if obj.Options.DistributeTimeVariable
                updateVariableProp(obj, 'T','all', 'lb',t_var.lb, 'ub', t_var.ub, 'x0',t_var.x0);
            else
                updateVariableProp(obj, 'T','first', 'lb',t_var.lb, 'ub', t_var.ub, 'x0',t_var.x0);
            end
            
            if isfield(bounds.time,'duration')
                if isfield(bounds.time.duration,'lb') && isfield(bounds.time.duration,'ub')
                    updateConstrProp(obj, 'timeDuration','first', 'lb', ...
                        bounds.time.duration.lb, 'ub', ...
                        bounds.time.duration.ub);
                elseif isfield(bounds.time.duration,'lb')
                    updateConstrProp(obj, 'timeDuration','first', 'lb', ...
                        bounds.time.duration.lb);
                elseif isfield(bounds.time.duration,'ub')
                    updateConstrProp(obj, 'timeDuration','first', 'ub', ...
                        bounds.time.duration.ub);
                end
            end
        end
        
    end
    
    % states as the decision variables
    if isfield(bounds,'states')
        if isa(obj.Plant,'ContinuousDynamics')
            state_names = {'x','dx','ddx'};
        elseif isa(obj.Plant,'DiscreteDynamics')
            state_names = {'x','dx','xn','dxn'};
        else
            state_names = {};
        end
        for i=1:length(state_names)
            s_name = state_names{i};
            if isfield(bounds.states,s_name)
                if isfield(bounds.states.(s_name),'lb')
                    updateVariableProp(obj, s_name,'all', 'lb',bounds.states.(s_name).lb);
                end
                if isfield(bounds.states.(s_name),'ub')
                    updateVariableProp(obj, s_name,'all', 'ub',bounds.states.(s_name).ub);
                end
                if isfield(bounds.states.(s_name),'x0')
                    updateVariableProp(obj, s_name,'all', 'x0',bounds.states.(s_name).x0);
                end
                if isfield(bounds.states.(s_name), 'initial')
                    x0 = bounds.states.(s_name).initial;
                    obj = updateVariableProp(obj, s_name, 'first', 'lb', x0, 'ub', x0, 'x0', x0);
                end
                
                if isfield(bounds.states.(s_name), 'terminal')
                    xf = bounds.states.(s_name).terminal;
                    obj = updateVariableProp(obj, s_name, 'last', 'lb', xf, 'ub', xf, 'x0', xf);
                end
            end
        end
    end
    
    % inputs as the decision variables
    if isfield(bounds,'inputs')
        input_groups = {'Control','ConstraintWrench','External'};
        for i=1:3
            input_group = input_groups{i};
            if ~isfield(bounds.inputs, input_group)
                continue;
            end
            input_names = fieldnames(obj.Plant.Inputs.(input_group));
            for j = 1:length(input_names)
                i_name = input_names{j};
                if isfield(bounds.inputs.(input_group),i_name)
                    if isfield(bounds.inputs.(input_group).(i_name),'lb')
                        updateVariableProp(obj, i_name,'all', 'lb',bounds.inputs.(input_group).(i_name).lb);
                    end
                    if isfield(bounds.inputs.(input_group).(i_name),'ub')
                        updateVariableProp(obj, i_name,'all', 'ub',bounds.inputs.(input_group).(i_name).ub);
                    end
                    if isfield(bounds.inputs.(input_group).(i_name),'x0')
                        updateVariableProp(obj, i_name,'all', 'x0',bounds.inputs.(input_group).(i_name).x0);
                    end
                end
            end
        end
    end
    
    % parameters as the decision variables
    if ~isempty(fieldnames(obj.Plant.Params)) && isfield(bounds,'params')
        param_names = fieldnames(obj.Plant.Params);
        if obj.Options.DistributeParameters
            node = 1:obj.NumNode;
        else
            node = 1;
        end
        for j = 1:length(param_names)
            p_name = param_names{j};
            if isfield(bounds.params,p_name)
                if isfield(bounds.params.(p_name),'lb') && isfield(bounds.params.(p_name),'ub')
                    updateVariableProp(obj, p_name,node, 'lb',bounds.params.(p_name).lb, 'ub',bounds.params.(p_name).ub);
                elseif isfield(bounds.params.(p_name),'lb')
                    updateVariableProp(obj, p_name,node, 'lb',bounds.params.(p_name).lb);
                elseif isfield(bounds.params.(p_name),'ub')
                    updateVariableProp(obj, p_name,node, 'ub',bounds.params.(p_name).ub);
                end
                if isfield(bounds.params.(p_name),'x0')
                    updateVariableProp(obj, p_name,node, 'x0',bounds.params.(p_name).x0);
                end
            end
        end
    end
end