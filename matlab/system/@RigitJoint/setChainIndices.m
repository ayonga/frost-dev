function obj = setChainIndices(obj, indices)
    % Set the kinematic chain indices of the parent reference
    % frames
    %
    % Parameters:
    % indices: the index vector @type rowvec
    
    assert(isvector(indices) & isequal(fix(indices),indices),...
        'The indices vector must be a positive integers.');
    
    if iscolumn(indices)
        indices = transpose(indices);
    end
    
    obj.ChainIndices = indices;
end