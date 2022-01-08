function obj = addParam(obj, params)
    % addParam(obj, params) adds parameters to the dynamical
    % system
    %
    % Parameters:
    %  params (repeatable): the parameter variables
    
    arguments
        obj DynamicalSystem        
    end
    
    arguments (Repeating)
        params ParamVariable
    end
    
    
    for i=1:length(params)
        name = params{i}.Name;
        
        if isfield(obj.Params, name)
            warning('The states (%s) has been already defined.\n',name);
        else
            obj.Params.(name) = params{i};            
            obj.params_.(name) = params{i}.Value;
        end
    end
    
    
end