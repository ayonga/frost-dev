function [costArray, costInfos] = getCostInfos(obj)
    % This function returns the indexing information of the cost
    % function array, including the Gradient and Hessian (if
    % applicable) sparse structures.
    %
    % Return values:
    %  costArray: An array of cost function @type NlpCost
    %  costInfos: A structure contains other pre-computed
    %  information regarding cost array. @type struct
    %
    % Required fields of costInfos:
    %  nnzGrad: The number of nonzero entries in the objective
    %  gradient vector @type integer
    %  gradSparseIndices: row and column indices of the  nonzero
    %  entries in the sparse Gradient vector @type matrix
    %  nnzHess: The number of nonzero entries in the cost portion
    %  of the Hessian @type integer
    %  hessSparseIndices: row and column indices of the nonzero
    %  entries in the sparse Hessian matrix associated with the
    %  cost function @type matrix
    
    % generate indexing first
    obj = genCostIndices(obj);
    
    
    nCosts  = numel(obj.costArray);
    nnzGrad = sum([obj.costArray.nnzJac]);
    
    gradSparseIndices = ones(nnzGrad,2);
    
    for i=1:nCosts
        cost = obj.costArray(i);
        jac_struct = cost.jac_struct;
        j_index = cost.j_index;
        dep_indices = cost.deps;
        
        
        gradSparseIndices(j_index,2) = dep_indices(jac_struct(:,2));
    end
    
    if obj.options.withHessian
        nnzHess = sum([obj.costArray.nnzHess]);
        hessSparseIndices = ones(nnzHess,2);
        
        for i=1:nCosts
            cost = obj.costArray(i);
            hess_struct = cost.hess_struct;
            h_index = cost.h_index;
            dep_indices = cost.deps;
            
            if ~cost.is_linear
                hessSparseIndices(h_index,1) = dep_indices(hess_struct(:,1));
                hessSparseIndices(h_index,2) = dep_indices(hess_struct(:,2));
            end
        end
    else
        nnzHess = [];
        hessSparseIndices = [];
    end
    
    costArray = obj.costArray;
    
    costInfos = struct();
    costInfos.nnzGrad = nnzGrad;
    costInfos.gradSparseIndices = gradSparseIndices;
    costInfos.nnzHess = nnzHess;
    costInfos.hessSparseIndices = hessSparseIndices;
end