function obj = setFuncIndices(obj, index)
    % Sets indinces of the Nlp Function
    %
    % Parameters:
    %  index: the indices of the function @type integer

    % If an offset is not specified, set it to zero.
    
    assert(length(index) == obj.Dimension, ...
        'The length of the variable indices must be equal to the dimension of the NlpVariable object.');
    
    obj.FuncIndices = index;
end