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
    for i=1:3
        switch i
            case 1
                input = obj.Plant.Inputs.Control;
                if isfield(bounds,'Control')
                    input_bounds = bounds.Control;
                else
                    input_bounds = struct();
                end
            case 2
                input = obj.Plant.Inputs.ConstraintWrench;
                if isfield(bounds,'ConstraintWrench')
                    input_bounds = bounds.ConstraintWrench;
                else
                    input_bounds = struct();
                end
            case 3
                input = obj.Plant.Inputs.External;
                if isfield(bounds,'External')
                    input_bounds = bounds.External;
                else
                    input_bounds = struct();
                end
        end
        
        
        input_names = fieldnames(input);
        
        
        for j=1:length(input_names)
            
            i_name = input_names{j};
            
            var = struct();
            var.Name = i_name;
            siz = size(input.(i_name));
            var.Dimension = prod(siz); %#ok<PSIZE>
            if isfield(input_bounds,i_name)
                if isfield(input_bounds.(i_name),'lb')
                    var.lb = input_bounds.(i_name).lb;
                end
                if isfield(input_bounds.(i_name),'ub')
                    var.ub = input_bounds.(i_name).ub;
                end
                if isfield(input_bounds.(i_name),'x0')
                    var.x0 = input_bounds.(i_name).x0;
                end
            end
            % input variables are defined at all nodes
            obj = addVariable(obj, i_name, 'all', var);
            
            % check if there are limiting conditions for states at the
            % initial/ternimal points
            if isfield(input_bounds,i_name)
                if isfield(input_bounds.(i_name), 'initial')
                    obj = updateVariableProp(obj, i_name, 'first', input_bounds.(i_name).initial);
                end
                
                if isfield(input_bounds.(i_name), 'terminal')
                    obj = updateVariableProp(obj, i_name, 'last', input_bounds.(i_name).terminal);
                end
            end
        end
    end
end