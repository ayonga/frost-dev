function obj = setChild(obj, child)
    % set the child link frame
    %
    % Parameters:
    % child: the child link frame object @type char
    
    assert(ischar(child),...
        'The child link name must be a character vector.');
    obj.Child = child;
    
end