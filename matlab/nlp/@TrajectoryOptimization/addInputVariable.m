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
        input_var = inputs.(i_name);
        if isfield(bounds,i_name)
            input_bound = bounds.(i_name);
            lb = [];
            ub = [];
            x0 = [];
            if isfield(input_bound,'lb')
                lb = input_bound.lb;
            end
            if isfield(input_bound,'ub')
                ub = input_bound.ub;
            end
            if isfield(input_bound,'x0')
                x0 = input_bound.x0;
            end
            
            % input variables are defined at all nodes
            obj = addVariable(obj, 'all', input_var, 'lb', lb, 'ub', ub, 'x0', x0);
        
        
            % check if there are limiting conditions for states at the
            % initial/ternimal points
            if isfield(input_bound, 'initial')
                u0 = input_bound.initial;
                obj = updateVariableProp(obj, i_name, 'first', 'lb',u0, 'ub', u0, 'x0', u0);
            end
            
            if isfield(input_bound, 'terminal')
                uf = input_bound.terminal;
                obj = updateVariableProp(obj, i_name, 'last', 'lb',uf, 'ub', uf, 'x0', uf);
            end
        end
    end
end