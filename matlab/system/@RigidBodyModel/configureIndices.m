function obj = configureIndices(obj)
    % Configure joint/state indices for fast operation
    %
    % 

    obj.qeIndices  = cumsum(ones(obj.nDof,1));
    obj.dqeIndices = obj.qeIndices + obj.nDof;

    if obj.nBaseDof ~= 0
        % indices of floating base coordinates
        obj.qbIndices  = cumsum(ones(obj.nBaseDof,1));
        obj.dqbIndices = obj.qbIndices + obj.nDof;
        % Indices of body coordinates
        obj.qIndices   = obj.qeIndices(obj.nBaseDof+1:obj.nDof);
        obj.dqIndices  = obj.qIndices + obj.nDof;
    else
        obj.qbIndices  = [];
        obj.dqbIndices = [];
        
        obj.qIndices   = obj.qeIndices;
        obj.dqIndices  = obj.dqeIndices;
    end
    
   

    
end
