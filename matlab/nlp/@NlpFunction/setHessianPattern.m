function obj = setHessianPattern(obj, hes_sp, sp_form)
    % This function configure the sparsity pattern of the Hessian
    % of the function
    %
    % The form of given sparsity pattern is determined by the input
    % argument 'sp_form'. It can be one of the followings:
    %  'MatrixForm': the sparsity pattern is given as a matrix
    %  (dense or sparse). In this case we extract the row and column
    %  indices of non-zero elements from this matrix            
    %  'Indexform': the sparsity pattern is directly given as
    %  vectors row and column indices of non-zero entries
    %
    % @note In MATLAB's sparse matrix, the values of same set of
    % row and column indices are added together. For example,
    % sparse([1;1],[1;1],[1,2]) will results in a sparse matrix
    % with 1+2 = 3 at entry (1,1).
    %
    % Parameters:
    %  hes_sp: a matrix array consists of sparsity pattern of Hessian
    %  of each element of the function @type cell 
    %  sp_form: the type of given sparsity pattern. @type char

    % default form 
    if nargin < 3
        sp_form = 'MatrixForm';
    end

    dimDeps = sum([obj.DepVariables.Dimension]);

    if isempty(hes_sp)
        obj.Type = NlpFunction.LINEAR;
        obj.HessPattern.Rows = [];
        obj.HessPattern.Cols = [];
    else

        switch sp_form
            case 'MatrixForm'

                [m, n, n_mat] = size(hes_sp);


                assert(n_mat == obj.Dimension && m==dimDeps && n==dimDeps,...
                    'NlpFunction:wrongDimension',...
                    ['The size of the Hessian matrix is incorrect.\n',...
                    'It must be a %d x %d x %d matrix.\n'], ...
                    dimDeps, dimDeps, obj.Dimension);

                % check the dimension
                sp_rows = cell(n_mat,1);
                sp_cols = cell(n_mat,1);
                for i=1:n_mat
                    [sp_rows{i}, sp_cols{i}] = find(hes_sp(:,:,i));
                end
                obj.HessPattern.Rows = vertcat(sp_rows{:});
                obj.HessPattern.Cols = vertcat(sp_cols{:});


            case 'IndexForm'

                % check if the maximum index exceeds the size of the
                % function or dependent variabbles
                m = max(hes_sp(:,1)); % the maximum row index
                n = max(hes_sp(:,2)); % the maximum column index

                assert(m <= dimDeps && n <= dimDeps,...
                    'NlpFunction:wrongDimension',...
                    'The size of the Hessian matrix is incorrect.\n');

                obj.HessPattern.Rows = hes_sp(:,1);
                obj.HessPattern.Cols = hes_sp(:,2);


            otherwise
                error('Unspecified form of the sparsity pattern.\n');
        end
    end
    obj.nnzHess = length(obj.HessPattern.Rows);
end