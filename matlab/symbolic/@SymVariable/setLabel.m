function obj = setLabel(obj, label)
    % set label to each componenent

    arguments
        obj 
        label cell {iscellstr(label)}
    end
    
    
    
    assert(numel(label) == prod(dimension(obj)),...
        'The (label) must be a cellstr array of the same number of elements as the SymVariables.'); %#ok<PSIZE>
%     assert(iscolumn(obj),...
%         'The (label) only works with column vector.');
    
    obj.label = label;


end