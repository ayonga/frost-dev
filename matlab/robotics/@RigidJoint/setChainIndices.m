function obj = setChainIndices(obj, indices)
    % Set the kinematic chain indices of the parent reference
    % frames
    %
    % Parameters:
    % indices: the index vector @type rowvec
    
    arguments
        obj
        indices (1,:) double {mustBeVector,mustBeInteger}
    end
    
    obj.ChainIndices = indices;
end