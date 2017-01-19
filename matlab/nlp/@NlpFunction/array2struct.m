function output_struct = array2struct(obj, varargin)
    % Converts an array of NLPFunction objects into a struct of array with
    % some specified modification.
    %
    % Parameters:
    %  varargin: name-value pairs of options
    %
    % Return values:
    % output_struct: a structure of arrays of NLP functions @type struct
    %
    %
    % Required fields for output_struct:
    %  numFuncs: the number of sub-functions @type integer
    %  Funcs: a cell array contains the name of sub-functions @type
    %  char
    %  FuncIndices: a cell array contains a vector of the indices of
    %  the function among the entire NLP function array @type colvec
    %  JacFuncs: a cell array contains the name of the first-order
    %  derivative of sub-functions @type char
    %  nnzJac: the total number of non-zeros in the entire Jacobian
    %  matrix @type integer
    %  DepIndices: a cell array contains a vector of the indices of all
    %  dependent variables @type colvec
    %  AuxData: a cell array of AuxData for each sub-functions @type
    %  cell
    %  nzJacRows: a vector of the row indices of non-zeros in the
    %  entire first-order derivative (Gradient) @type colvec
    %  nzJacCols: a vector of the column indices of non-zeros in the
    %  entire first-order derivative (Gradient) @type colvec
    %  nzJacIndices: a cell array contains a vector of the indices of
    %  the non-zeros of the Jacobian @type colvec
    %  Dimension: the total dimension of the NLP functions @type double
    %  LowerBound: a vector of lower boundary of all NLP functions 
    %  @type colvec
    %  UpperBound: a vector of upper boundary of all NLP functions 
    %  @type colvec
    %
    % Optional Fields for output_struct:
    %  HessFuncs: a cell array contains the name of the second-order
    %  derivative of sub-functions @type char
    %  nnzHess: the total number of non-zeros in the entire Hessian
    %  matrix @type integer
    %  nzHessRows: a vector of the row indices of non-zeros in the
    %  entire second-order derivative (Hessian) @type colvec
    %  nzHessCols: a vector of the column indices of non-zeros in the
    %  entire second-order derivative (Hessian) @type colvec
    %  nzHessIndices: a cell array contains a vector of the indices of
    %  the non-zeros of the Hessian @type colvec
    
    
    % parse the input argument to 'options' structure
    options = struct(varargin{:});
    
    
    output_struct = struct;

    output_struct.numFuncs = numel(obj(:));
    
    output_struct.nnzJac = sum(vertcat(obj(:).nnzJac));
    
    
    
    % convert the array of objects into a structure of arrays
    output_struct.Funcs = {obj(:).Name};
    output_struct.DepIndices = {obj(:).DepIndices};
    output_struct.AuxData = {obj(:).AuxData};
    output_struct.JacFuncs = {obj(:).JacFunc};    
    
    % preallocate
    output_struct.nzJacRows = ones(output_struct.nnzJac,1);
    output_struct.nzJacCols = ones(output_struct.nnzJac,1);
    output_struct.FuncIndices = cell(output_struct.numFuncs,1);
    output_struct.nzJacIndices = cell(output_struct.numFuncs,1);
    
    % if user-defined Hessian functions are provided
    if options.DerivativeLevel == 2         
        output_struct.HessFuncs =  {obj(:).HessFunc};
        output_struct.nnzHess = sum(vertcat(obj(:).nnzHess));
        output_struct.nzHessRows = ones(output_struct.nnzHess,1);
        output_struct.nzHessCols = ones(output_struct.nnzHess,1);
        output_struct.nzHessIndices = cell(output_struct.numFuncs,1);
    end
    
    % initialize offsets of indices to be zero
    func_index_offset = 0;
    jac_index_offset = 0;
    hes_index_offset = 0;
    
    % index the array of objective functions, and configure the sparsity
    % pattern of the derivatives
    for i=1:output_struct.numFuncs
        % set the indices of constraints
        func_index = func_index_offset + ...
            cumsum(ones(1,obj(i).Dimension));
        func_index_offset = func_index(end);
        output_struct.FuncIndices{i} = func_index;
        
        
        % set the indices of non-zero Jacobian elements
        jac_index = jac_index_offset + ...
            cumsum(ones(1,obj(i).nnzJac));
        jac_index_offset = jac_index(end);
        output_struct.nzJacIndices{i} = jac_index;
        
        % get the sparsity pattern (i.e., the indices of non-zero elements)
        % of the Jacobian of the current function
        jac_pattern = obj(i).JacPattern;
        
        
        % retrieve the indices of dependent variables 
        dep_indices = output_struct.DepIndices{i};
        
        
        %| @note The JacPattern gives the indices of non-zero Jacobian
        % elements of the current function. 
        switch options.Type
            case 'list' % such as constraints
                output_struct.nzJacRows(jac_index) = func_index(jac_pattern.Rows);
            case 'sum' % such as cost function
                output_struct.nzJacRows(jac_index) = ones(size(jac_pattern.Rows));
        end
        
        output_struct.nzJacCols(jac_index) = dep_indices(jac_pattern.Cols);
        
        
        if options.DerivativeLevel == 2 
            % if user-defined Hessian functions are provided
            output_struct.nnzHess =  sum(vertcat(obj(:).nnzHes));
            hes_index = hes_index_offset + ...
                cumsum(ones(1,obj(i).nnzHess));
            if ~isempty(hes_index)
                hes_index_offset = hes_index(end);
                % set the indices of non-zero Hessian elements
                output_struct.nzHessIndices{i} = hes_index;
                % get the sparsity pattern (i.e., the indices of non-zero elements)
                % of the Jacobian of the current function
                hess_pattern = obj(i).HessPattern;
                output_struct.nzHessRows(hes_index) = dep_indices(hess_pattern.Rows);
                output_struct.nzHessCols(hes_index) = dep_indices(hess_pattern.Cols);
            end
        end
    end
    
    
    
    output_struct.Dimension = sum([obj(:).Dimension]);
    output_struct.LowerBound = vertcat(obj(:).LowerBound);
    output_struct.UpperBound = vertcat(obj(:).UpperBound);
end

