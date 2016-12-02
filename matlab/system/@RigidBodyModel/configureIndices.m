function obj = configureIndices(obj)
    % Configure joint/state indices for fast operation
    %
    % 

    obj.qe_indices  = cumsum(ones(obj.n_dofs,1));
    obj.dqe_indices = obj.qe_indices + obj.n_dofs;

    if obj.n_base_dofs ~= 0
        % indices of floating base coordinates
        obj.qb_indices  = cumsum(ones(obj.n_base_dofs,1));
        obj.dqb_indices = obj.qb_indices + obj.n_dofs;
        % Indices of body coordinates
        obj.q_indices   = obj.qe_indices(obj.n_base_dofs+1:obj.n_dofs);
        obj.dq_indices  = obj.q_indices + obj.n_dofs;
    else
        obj.qb_indices  = [];
        obj.dqb_indices = [];
        
        obj.q_indices   = obj.qe_indices;
        obj.dq_indices  = obj.dqe_indices;
    end
    
   

    
end
