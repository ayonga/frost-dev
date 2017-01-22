function obj = setDimension(obj, dim)
    % Sets the dimension of the NLP variable vector
    %
    % Parameters:
    % dim: the dimension of the vector @type double
    
    assert(isscalar(dim) && dim >=0, 'The dimension must be a scalar positive value.');

    

    obj.Dimension = dim;


end