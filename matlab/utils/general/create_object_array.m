function vars = create_object_array(type, length, index, varargin)
    % Creates an array of NlpFunction objects.
    %
    %
    % Parameters:    
    % type: the type of the object @type char
    % length: the maximum length of the array @tyep double
    % index: the indices of non-empty objects @type rowvec
    % varargin: variable input arguments for property values non-empty
    % NlpFunction @copydoc NlpVariable.updateProp
    % 
    % @see NlpVariable

    
    assert(isvector(index), ...
        'The node list must be given as a vector of positive integers.');
    
    
    
    % first create an array of empty objects
    vars(length) = fevel(type);
    
    % update properties for non-empty objects
    for i = index
        vars(i) = fevel(type, varargin{:});
    end

end