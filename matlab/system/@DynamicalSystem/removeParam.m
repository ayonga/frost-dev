function obj = removeParam(obj, param_names)
    % Remove parameter variables of the dynamical system
    %
    % Parameters:
    %  param_names (repeatable): the parameter variables to be removed
    
    arguments
        obj DynamicalSystem        
    end
    
    arguments (Repeating)
        param_names char
    end
    
    for i=1:length(param_names)
        name = param_names{i};
        
        if isfield(obj.Params, name)
            obj.Params = rmfield(obj.Params,name);
            obj.params_ = rmfield(obj.params_,name);
        else
            warning('A parameter variable name (%s) does not exist.\n',p);
        end
    end
    
end