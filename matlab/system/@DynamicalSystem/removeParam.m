function obj = removeParam(obj, param_name)
    % Remove parameter variables of the dynamical system
    %
    % Parameters:
    %  param_name: the name of the parameter variables to be removed 
    %  @type cellstr
    
    
    assert(ischar(param_name) || iscellstr(param_name), ...
        'The parameter name must be a character vector or cellstr.');
    if ischar(param_name), param_name = cellstr(param_name); end
    
    
    for i=1:length(param_name)
        p = param_name{i};
        
        if isfield(obj.Params, p)
            obj.Params = rmfield(obj.Params,p);
        else
            error('A parameter variable name (%s) does not exist.\n',p);
        end
    end
end