function obj = removeInput(obj, category, name)
    % Remove input variables of the dynamical system
    %
    % Parameters:
    %  category: the category of the input @type char
    %  name: the name of the input variables to be removed 
    %  @type cellstr
    
    
    validatestring(category,{'Control','ConstraintWrench','External'});
    
    assert(ischar(name) || iscellstr(name), ...
        'The name must be a character vector or cellstr.');
    if ischar(name), name = cellstr(name); end
    
    
    for i=1:length(name)
        u = name{i};
        
        if isfield(obj.Inputs.(category), u)
            obj.Inputs.(category) = rmfield(obj.Inputs.(category),u);
            obj.Gmap.(category) = rmfield(obj.Gmap.(category),u);
            obj.Gvec.(category) = rmfield(obj.Gvec.(category),u);
        else
            error('A input variable name (%s) of category (%s) does not exist.\n',u,category);
        end
    end
end