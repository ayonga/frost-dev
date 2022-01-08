function obj = removeInput(obj, input_names)
    % removeInput(model, inputs) removes input variables from the dynamical
    % system.
    %
    % Parameters:
    %  input_names (repeatable): the input variables to be removed
    
    arguments
        obj DynamicalSystem        
    end
    
    arguments (Repeating)
        input_names char
    end
    
    for i=1:length(input_names)
        name = input_names{i};
        
        if isfield(obj.Inputs, name)
            obj.Inputs.(name) = rmfield(obj.Inputs,name);   
            obj.inputs_.(name) = rmfield(obj.inputs_,name);
        else            
            warning('The input variable name (%s) does not exist.\n',name);
        end
    end
    
    
end
