function [constrArray, constrInfos] = getConstrInfosIpopt(obj)
    % This function returns the indexing information of the
    % constraints function array, including the Gradient and
    % Hessian (if applicable) sparse structures.
    %
    % Return values:
    %  constrArray: An array of constraints @type NlpConstr
    %  constrInfos: A structure contains other pre-computed
    %  information regarding constraints array. @type struct
    %
    % Required fields of constrInfos:
    %  dimsConstr: The dimension of constraints @type integer
    %  cl: The lower bound of constraints @type colvec
    %  cu: The upper bound of constraints @type colvec
    %  nnzJac: The number of nonzero entries in the objective
    %  gradient vector @type integer
    %  gradSparseIndices: row and column indices of the  nonzero
    %  entries in the sparse Gradient vector @type matrix
    %  nnzHess: The number of nonzero entries in the cost portion
    %  of the Hessian @type integer
    %  hessSparseIndices: row and column indices of the nonzero
    %  entries in the sparse Hessian matrix associated with the
    %  cost function @type matrix
    
    nConstr  = numel(obj.constrArray);
    
    % dimension of the entire constraints vector
    dimConstr = sum([obj.constrArray.dims]);
    
    % number of non-zero elements in the Jacobian matrix
    nnzJac = sum([obj.constrArray.nnzJac]);
    
    % pre-allocation
    jacSparseIndices = ones(nnzJac,2);
    cl = zeros(dimConstr,1);
    cu = zeros(dimConstr,1);
    
    for i=1:nConstr
        constr = obj.constrArray(i);
        
        % sparse structure of the Jacobian matrix
        jac_struct = constr.jac_struct;
        % get indices of the constraint
        c_index = constr.c_index;
        % get jacobian entry indices
        j_index = constr.j_index;
        % get indices of dependent variables
        dep_indices = constr.deps;
        
        % row indices of non-zero entries
        jacSparseIndices(j_index,1) = c_index(jac_struct(:,1));
        % column indices of non-zero entries
        jacSparseIndices(j_index,2) = dep_indices(jac_struct(:,2));
        
        
        cl(c_index,1) = constr.cl;
        cu(c_index,1) = constr.cu;
    end
    
    if obj.options.withHessian
        % number of non-zero elements in the Hessian matrix
        nnzHess = sum([obj.constrArray.nnzHess]);
        % pre-allocation
        hessSparseIndices = ones(nnzHess,2);
        
        for i=1:nConstr
            constr = obj.constrArray(i);
            
            % sparse structure of the Hessian matrix
            hess_struct = constr.hess_struct;
            % get indices of non-zero entries of Hessian matrix
            h_index = constr.h_index;
            % get indices of dependent variables
            dep_indices = constr.deps;
            
            if ~constr.is_linear
                hessSparseIndices(h_index,1) = dep_indices(hess_struct(:,1));
                hessSparseIndices(h_index,2) = dep_indices(hess_struct(:,2));
            end
        end
    else
        nnzHess = [];
        hessSparseIndices = [];
    end
    
    constrArray = obj.constrArray;
    constrInfos = struct();
    constrInfos.dimConstr = dimConstr;
    constrInfos.cl = cl;
    constrInfos.cu = cu;
    constrInfos.nnzJac = nnzJac;
    constrInfos.jacSparseIndices = jacSparseIndices;
    constrInfos.nnzHess = nnzHess;
    constrInfos.hessSparseIndices = hessSparseIndices;
end