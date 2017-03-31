function obj = addInputVariable(obj, bounds)
    % Adds input variables as the NLP decision variables to the problem
    %
    % @note The input variables may includes the control inputs, as well as
    % external forces such as disturbance or contact wrenches.
    %
    % Parameters:
    %  bounds: a structed data stores the boundary information of the
    %  NLP variables @type struct
    
    
   % get basic information of the variables
    inputs = obj.Plant.Inputs;
    
    input_names = fieldnames(inputs);
    
    
    for j=1:length(input_names)
        
        i_name = input_names{j};
        
        var = struct();
        var.Name = i_name;
        siz = size(inputs.(i_name));
        var.Dimension = prod(siz); %#ok<PSIZE>
        if isfield(bounds,i_name)
            if isfield(bounds.(i_name),'lb')
                var.lb = bounds.(i_name).lb;
            end
            if isfield(bounds.(i_name),'ub')
                var.ub = bounds.(i_name).ub;
            end
            if isfield(bounds.(i_name),'x0')
                var.x0 = bounds.(i_name).x0;
            end
        end
        % input variables are defined at all nodes
        obj = addVariable(obj, i_name, 'all', var);
        
        % check if there are limiting conditions for states at the
        % initial/ternimal points
        if isfield(bounds,i_name)
            if isfield(bounds.(i_name), 'initial')
                obj = updateVariableProp(obj, i_name, 'first', bounds.(i_name).initial);
            end
            
            if isfield(bounds.(i_name), 'terminal')
                obj = updateVariableProp(obj, i_name, 'last', bounds.(i_name).terminal);
            end
        end
    end

end