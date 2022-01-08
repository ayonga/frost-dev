function obj = addInput(obj, inputs)
    % addInput(obj, inputs) adds inputs variables to the dynamical
    % system
    %
    % Parameters:
    %  inputs (repeatable): the input variables
    
    arguments
        obj DynamicalSystem        
    end
    
    arguments (Repeating)
        inputs InputVariable
    end
    
    for i=1:length(inputs)
        name = inputs{i}.Name;
        
        if isfield(obj.Inputs, name)
            warning('The input variable (%s) has been already defined.\n',name);
        else
            obj.Inputs.(name) = inputs{i};            
            obj.inputs_.(name) = nan(size(inputs{i}));
        end
    end
    
    
end
