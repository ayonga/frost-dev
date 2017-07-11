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
        
        var = struct();
        var.Name = s_name;
        siz = size(states.(s_name));
        var.Dimension = prod(siz); %#ok<PSIZE>
        if isfield(bounds,s_name)
            if isfield(bounds.(s_name),'lb')
                var.lb = bounds.(s_name).lb;
            end
            if isfield(bounds.(s_name),'ub')
                var.ub = bounds.(s_name).ub;
            end
            if isfield(bounds.(s_name),'x0')
                var.x0 = bounds.(s_name).x0;
            end
        end
        % state variables are defined at all nodes
        obj = addVariable(obj, s_name, 'all', var);
        
        % check if there are limiting conditions for states at the
        % initial/ternimal points
        if isfield(bounds,s_name)
            if isfield(bounds.(s_name), 'initial')
                x0 = bounds.(s_name).initial;
                obj = updateVariableProp(obj, s_name, 'first', 'lb',x0, 'ub', x0, 'x0', x0);
            end
            
            if isfield(bounds.(s_name), 'terminal')
                xf = bounds.(s_name).terminal;
                obj = updateVariableProp(obj, s_name, 'last', 'lb',xf, 'ub', xf, 'x0', xf);
            end
        end
    end
    
    
    
    
    
    

end