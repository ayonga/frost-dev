function bounds= getBounds(obj)
    % bounds = getBounds(obj) returns a struct that contains the boundary
    % data of state/input/param variables defined for the system.
    
    bounds = struct('time',struct(),...
        'states',struct(),...
        'inputs',struct(),...
        'params',struct());
    
    
    
    state_names = fieldnames(obj.States);
    for i=1:numel(state_names)
        s_name = state_names{i};
        state  = obj.States.(s_name);
        bounds.states.(s_name).lb = state.LowerBound;
        bounds.states.(s_name).ub = state.UpperBound;
        x0 = (state.LowerBound + state.UpperBound)/2;        
        x0(isnan(x0)) = 0;
        bounds.states.(s_name).x0 = x0;
    end
    
    input_names = fieldnames(obj.Inputs);
    for i=1:numel(input_names)
        i_name = input_names{i};
        input  = obj.Inputs.(i_name);
        bounds.inputs.(i_name).lb = input.LowerBound;
        bounds.inputs.(i_name).ub = input.UpperBound;
        x0 = (input.LowerBound + input.UpperBound)/2;   
        x0(isnan(x0)) = 0;
        bounds.inputs.(i_name).x0 = x0;
    end
    
    param_names = fieldnames(obj.Params);
    for i=1:numel(param_names)
        p_name = param_names{i};
        param  = obj.Params.(p_name);
        bounds.params.(p_name).lb = param.LowerBound;
        bounds.params.(p_name).ub = param.UpperBound;
        x0 = (param.LowerBound + param.UpperBound)/2;   
        x0(isnan(x0)) = 0;
        bounds.params.(p_name).x0 = x0;
    end
    
end

