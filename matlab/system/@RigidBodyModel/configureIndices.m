function obj = configureIndices(obj)
    % Configure joint/state indices for fast operation
    %
    % 

    obj.qeIndices  = cumsum(ones(obj.nDof,1));
    obj.dqeIndices = obj.qeIndices + obj.nDof;


    % Number and indices of floating base coordinates
    obj.qbIndices  = cumsum(ones(obj.nBase,1));
    obj.dqbIndices = obj.qbIndices + obj.nDof;

    
    nJoint = numel(obj.joints);
    % Indices of body coordinates
    obj.qIndices   = obj.nBase + cumsum(ones(nJoint,1));
    obj.dqIndices  = obj.qIndices + obj.nDof;

    
end
