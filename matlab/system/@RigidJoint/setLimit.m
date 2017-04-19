function obj = setLimit(obj, limit)
    % set the physical limits of the rigid joints
    %
    % Parameters:
    % limit: the physical limit @type struct
    
    assert(isstruct(limit),...
        'Expected a struct input. Instead the input argument is a %s object', class(limit));
    
    assert(all(isfield(limit,{'effort','lower','upper','velocity'})),...
        'The input struct should have the following fields: \n %s',implode({'effort','lower','upper','velocity'},', '));
    
    obj.Limit = limit;
end