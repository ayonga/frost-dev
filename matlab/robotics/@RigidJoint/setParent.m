function obj = setParent(obj, parent)
    % set the parent link frame
    %
    % Parameters:
    % parent: the parent link frame object @type char
    
    assert(ischar(parent),...
        'The parent link name must be a character vector.');
    obj.Parent = parent;
    
end