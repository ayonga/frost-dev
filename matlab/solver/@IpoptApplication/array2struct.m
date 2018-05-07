function func_struct = array2struct(obj, func_array, type, derivative_level)
    % Converts an array of NLPFunction objects into a struct of arrays with
    % some specified modification for fast computation in the NLP solver.
    % Typically a struct of array is more computationally efficent than
    % arrays of struct, and a struct is more computationally efficent than
    % a class object.
    %
    % Parameters:
    %  func_array: an array of NLP functions @type cell
    %  type: indicates whether ''stack'' the array or ''sum'' the array
    %  @type char
    %  derivative_level: the derivative level to be used @type double
    %
    % Return values:
    % func_struct: a structure of arrays of NLP functions @type struct
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
    
    if nargin <3
        type = 'stack';
    end
    if nargin < 4
        derivative_level = 1;
    end
    
    % get the total number of NlpFunction objects
    num_obj = numel(func_array);
    func_index_offset = 0;
    % update the function indices for each NlpFunctions
    switch type
        case 'stack'
            % typically used for constraints
            for i=1:num_obj
                % set the indices of constraints
                func_indics = func_index_offset + ...
                    cumsum(ones(1,func_array(i).Dimension));
                func_index_offset = func_indics(end);
                func_array(i) = setFuncIndices(func_array(i), func_indics);
                
            end
        case 'sum'
            % Typically used for objective functions
            dim = func_array(1).Dimension;
            for i=1:num_obj
                % set the indices of constraints
                func_indics = cumsum(ones(1,dim));
                func_array(i) = setFuncIndices(func_array(i), func_indics);
                
            end
        otherwise
            error('Unsupported type');
    end
    
    % construct a new cell array of the dependent objects
    deps_array_cell = arrayfun(@(x)getSummands(x), func_array, 'UniformOutput', false);
    deps_array = vertcat(deps_array_cell{:});
    n_deps = length(deps_array);
    for i=1:n_deps
        if isempty(deps_array(i).JacPattern)
            js = feval(deps_array(i).Funcs.JacStruct,0);
            if ~isempty(js)
                deps_array(i) = setJacobianPattern(deps_array(i),js,'IndexForm');
            end
        end
    end
    % initialize the output structure based on the deps_array.
    func_struct = struct;
    
    func_struct.numFuncs = length(deps_array);    
    func_struct.nnzJac = sum([deps_array.nnzJac]);
    
    
    
    % convert the array of objects into a structure of arrays
    func_struct.Names = arrayfun(@(x) x.Name, deps_array, 'UniformOutput', false);
    func_struct.Funcs = arrayfun(@(x) x.Funcs.Func, deps_array, 'UniformOutput', false);
    func_struct.JacFuncs = arrayfun(@(x) x.Funcs.Jac, deps_array, 'UniformOutput', false);  
    func_struct.JacStructFuncs = arrayfun(@(x) x.Funcs.JacStruct, deps_array, 'UniformOutput', false);  
    dep_indices = arrayfun(@(x) getDepIndices(x), deps_array, 'UniformOutput', false);
    func_struct.DepIndices = dep_indices;%cellfun(@(x)(vertcat(x)),dep_indices,'UniformOutput',false);
    func_struct.AuxData = arrayfun(@(x) x.AuxData, deps_array, 'UniformOutput', false);
    func_struct.FuncIndices = arrayfun(@(x) x.FuncIndices, deps_array, 'UniformOutput', false);
    % preallocate
    func_struct.nzJacRows = zeros(func_struct.nnzJac,1);
    func_struct.nzJacCols = zeros(func_struct.nnzJac,1);
    func_struct.nzJacIndices = cell(func_struct.numFuncs,1);
    
    % if user-defined Hessian functions are provided
    if derivative_level == 2         
        func_struct.HessFuncs =  arrayfun(@(x) x.Funcs.Hess, deps_array, 'UniformOutput', false);
        func_struct.nnzHess = sum([deps_array.nnzHess]);
        func_struct.nzHessRows = ones(func_struct.nnzHess,1);
        func_struct.nzHessCols = ones(func_struct.nnzHess,1);
        func_struct.nzHessIndices = cell(func_struct.numFuncs,1);
    end
    
    % initialize offsets of indices to be zero
    
    jac_index_offset = 0;
    hes_index_offset = 0;
    
    % index the array of objective functions, and configure the sparsity
    % pattern of the derivatives
    n_deps = length(deps_array);
    for i=1:n_deps
        
        % set the indices of non-zero Jacobian elements
        jac_index = jac_index_offset + ...
            cumsum(ones(1,deps_array(i).nnzJac));
        if ~isempty(jac_index)
            jac_index_offset = jac_index(end);
            func_struct.nzJacIndices{i} = jac_index;
            
            % get the sparsity pattern (i.e., the indices of non-zero elements)
            % of the Jacobian of the current function
            
            jac_pattern = deps_array(i).JacPattern;
            % retrieve the indices of dependent variables
            dep_indices = vertcat(func_struct.DepIndices{i}{:});
            func_indics = func_struct.FuncIndices{i};
            
            %| @note The JacPattern gives the indices of non-zero Jacobian
            % elements of the current function.
            func_struct.nzJacRows(jac_index) = func_indics(jac_pattern.Rows);
            
            func_struct.nzJacCols(jac_index) = dep_indices(jac_pattern.Cols);
        end
        
        if derivative_level == 2 
            % if user-defined Hessian functions are provided
            hes_index = hes_index_offset + ...
                cumsum(ones(1,deps_array(i).nnzHess));
            if ~isempty(hes_index)
                hes_index_offset = hes_index(end);
                % set the indices of non-zero Hessian elements
                func_struct.nzHessIndices{i} = hes_index;
                % get the sparsity pattern (i.e., the indices of non-zero elements)
                % of the Jacobian of the current function
                if isempty(deps_array(i).HessPattern)
                    hs = feval(deps_array(i).Funcs.HesStruct,0);
                    deps_array(i) = setHessianPattern(deps_array(i),hs,'IndexForm');
                    hess_pattern = deps_array(i).HessPattern;
                else
                    hess_pattern = deps_array(i).HessPattern;
                end
                
                func_struct.nzHessRows(hes_index) = dep_indices(hess_pattern.Rows);
                func_struct.nzHessCols(hes_index) = dep_indices(hess_pattern.Cols);
            end
        end
    end
    
    % Get the dimension and boundary values from the orignial function
    % array (not dependent array)
    func_struct.Dimension = sum([func_array.Dimension]);
    func_struct.LowerBound = vertcat(func_array.LowerBound);
    func_struct.UpperBound = vertcat(func_array.UpperBound);
    
    
end

