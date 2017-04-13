function obj = removeInput(obj, name)
    % Remove input variables of the dynamical system
    %
    % Parameters:
    %  name: the name of the input variables to be removed 
    %  @type cellstr
    
    
    assert(ischar(name) || iscellstr(name), ...
        'The name must be a character vector or cellstr.');
    if ischar(name), name = cellstr(name); end
    
    
    for i=1:length(name)
        u = name{i};
        
        if isfield(obj.Inputs, u)
            obj.Inputs = rmfield(obj.Inputs,u);
            obj.Gmap = rmfield(obj.Gmap,u);
            obj.Gvec = rmfield(obj.Gvec,u);
        else
            error('A input variable name (%s) does not exist.\n',u);
        end
    end
end