function obj = setLabel(obj, n, label)
    % Flatten the symbolic expression

    
    assert(iscellstr(label) && numel(label)==prod(n),...
        'The (label) must be a cellstr array of the same number of elements as the SymVariables.');
    assert(iscolumn(obj),...
        'The (label) only works with column vector.');
    
    obj.label = label;


end