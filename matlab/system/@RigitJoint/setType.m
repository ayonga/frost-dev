function obj = setType(obj, type)
    % Sets the joint type
    %
    % Parameters:
    % type: the joint type @type char
    
    valid_types = {'prismatic',...
        'revolute',...
        'continuous',...
        'fixed'};
    
    obj.Type = validatestring(type,valid_types);
    
end