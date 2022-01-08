function obj = addStateVariable(obj, bounds)
    % Adds state variables as the NLP decision variables to the problem
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    
    
    % get basic information of the variables
    states = obj.Plant.States;
    
    state_names = fieldnames(states);
    
    
    for j=1:length(state_names)
        
        s_name = state_names{j};
        state_var = states.(s_name);
        if isfield(bounds,s_name)
            state_bound = bounds.(s_name);
            lb = [];
            ub = [];
            x0 = [];
            if isfield(state_bound,'lb')
                lb = state_bound.lb;
            end
            if isfield(state_bound,'ub')
                ub = state_bound.ub;
            end
            if isfield(state_bound,'x0')
                x0 = state_bound.x0;
            end
            % state variables are defined at all nodes
            obj = addVariable(obj, 'all', state_var, 'lb', lb, 'ub', ub, 'x0', x0);
               
            if isfield(state_bound, 'initial')
                x0 = state_bound.initial;
                obj = updateVariableProp(obj, s_name, 'first', 'lb',x0, 'ub', x0, 'x0', x0);
            end
            
            if isfield(state_bound, 'terminal')
                xf = state_bound.terminal;
                obj = updateVariableProp(obj, s_name, 'last', 'lb',xf, 'ub', xf, 'x0', xf);
            end
        end
    end
    
    
    
    
    
    

end