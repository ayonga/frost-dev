function obj = setIndices(obj, index)
     % Sets indinces of the Nlp Variables
    %
    % Parameters:
    %  index: the indices of the variables @type integer

    
    assert(length(index) == obj.Dimension, ...
        'The length of the variable indices must be equal to the dimension of the NlpVariable object.');
    
    obj.Indices = index;
end