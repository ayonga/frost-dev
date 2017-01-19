function obj = setJacobianPattern(obj, jac_sp, sp_form)
    % This function configure the sparsity pattern of the Jacobian
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
    % Parameters:
    %  jac_sp: the sparsity pattern of the Jacobian @type matrix
    %  sp_form: the type of given sparsity pattern. @type char

    % default form 
    if nargin < 3
        sp_form = 'MatrixForm';
    end

    dimDeps = sum([obj.DepVariables.Dimension]);

    switch sp_form
        case 'MatrixForm'

            % check the dimension
            [m, n] = size(jac_sp);

            assert(m==obj.Dimension && n==dimDeps,...
                'NlpFunction:wrongDimension',...
                ['The size of the Jacobian matrix is incorrect.\n',...
                'It must be a %d x %d matrix.\n'], obj.Dimension, dimDeps);

            [rows, cols] = find(jac_sp);

            obj.JacPattern.Rows = rows;
            obj.JacPattern.Cols = cols;


        case 'IndexForm'

            % check if the maximum index exceeds the size of the
            % function or dependent variabbles
            m = max(jac_sp(:,1)); % the maximum row index
            n = max(jac_sp(:,2)); % the maximum column index

            assert(m <= obj.Dimension && n <= dimDeps,...
                'NlpFunction:maxIndex',...
                'The maximum non-zero index exceeds the size of the Jacobian matrix.\n');

            obj.JacPattern.Rows = jac_sp(:,1);
            obj.JacPattern.Cols = jac_sp(:,2);


        otherwise
            error('NlpFunction:incorrectForm',...
                ['Unspecified form of the sparsity pattern.\n'...
                'Please use either ''MatrixForm'' or ''IndexForm''.\n']);
    end

    obj.nnzJac = length(obj.JacPattern.Rows);
end