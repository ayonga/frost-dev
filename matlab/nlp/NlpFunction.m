classdef NlpFunction < handle
    % This class provides a data structure for a optimization function.
    % This function could be either a constraint or a objective function of
    % the problem.
    %
    % To define a NlpFunction object, a user-defined function file must be
    % created first. It could be either MATLAB m file or mex file. The name
    % of the file should be the same as the name of the NlpFunction.
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties(Constant,Hidden)
        LINEAR = true;
        NONLINEAR = false;
    end
    
    
    properties
        
        % This property specifies whether the function is the linear
        % function of dependent variables
        %
        % @type logical
        type
        
        % An identification of the object
        %
        % @type char
        name
        
        % It gives a quick access to the dimension of the function output
        % without actually evaluating the function
        %
        % @type integer
        dimension
        
        % An array of dependent NLP variables
        %
        % @type NlpVariable
        dep_vars
                
        % Stores the indices of all dependent variables in a vector
        %
        % @type colvec
        dep_indices
        
        % Stores the indices of the function
        %
        % @type colvec
        fun_indices
        
        % Stores the indices of the non-zero elements in the first-order
        % jacobian
        %
        % @type colvec
        nnz_jac_indices
        
        % Stores the indices of the non-zero elements in the Hessian matrix
        % of the Lagrangian
        %
        % @type colvec
        nnz_hess_indices
        
        % The name of the function that computes the Jacobian of the
        % function
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type char
        jac_func
        
        
        % The name of the function that computes the Jacobian of the
        % function
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type char
        hess_func
        
        % A two-vector structure that specifies the non-zero structure of
        % the first order Jacobian of the function with respect to the
        % dependent variables. The first vector determines the row indices
        % of the all non-zero elements in the Jacobian matrix, and the
        % second vector determines the colomn indices of the all non-zero
        % elements in the Jacobian matrix. For the gradient of the cost
        % function, the first vector should consists of all '1's.
        % 
        % Required fields of jac_nz_pattern:
        %  rows: the row indices of non-zero elements
        %  cols: the column indices of non-zero elements
        %
        % @see sparsematrix 
        % 
        % @type struct
        jac_nz_pattern        
        
        
        
        % A two-vector structure that specifies the non-zero structure of
        % the second order Hessian of the Lagrangian function with respect
        % to the dependent variables. The first vector determines the row
        % indices of the all non-zero elements in the Hessian matrix, and
        % the second vector determines the colomn indices of the all
        % non-zero elements in the Hessian matrix.
        % 
        % Required fields of hess_nz_pattern:
        %  rows: the row indices of non-zero elements
        %  cols: the column indices of non-zero elements
        %
        % @see sparsematrix 
        % 
        % @type struct
        hess_nz_pattern
        
        % The number of nonzero entries in the Jacobian matrix
        %
        % @type integer
        nnz_jac
        
        
        
        % The number of nonzero entries in the Hessian matrix
        % 
        % @type integer
        nnz_hess
        
        
        % A constant array of auxiliary data that will be used to construct
        % the function handles
        %
        % @type matrix
        auxdata
        
        % The lower boundary values of the function
        %
        % @type colvec
        cl
        
        % The upper boundary values of the function
        %
        % @type colvec
        cu
        
    end
    
        
    methods
        function obj = NlpFunction(name, type, auxdata)
            % The class constructor function.
            %
            % Parameters:            
            %  name: the name of the function. @type char        
            %  type: the type of the function. @type char
            %  auxdata: a row vector of constant arguments of the function.
            %  @type rowvec
            % 
            % @attention The 'auxdata' argument must be an 1-dimensional
            % vector of constants.
            
            
            % parse input arguments
            %             p = inputParser;
            %             p.addRequired('name',@ischar);
            %             p.addOptional('type','Nonlinear', @ischar);
            %             p.addOptional('auxdata',[],@isnumeric || @iscell);
            %
            %             p.parse(varargin{:});
            %             obj.name = p.Results.name;
            %             obj.auxdata = p.Results.auxdata;
            
            % MATLAB suggests a class must support the no input argument
            % constructor syntax.
            if nargin == 0
                return;
            end
            
            
            obj.name = name;
            
            if nargin > 1
                
                % specify the function type
                if strcmpi(type, 'Linear')
                    obj.type = NlpFunction.LINEAR;
                elseif strcmpi(type, 'Nonlinear')
                    obj.type = NlpFunction.NONLINEAR;
                else
                    error('NlpFunction:incorrectFunctionType',...
                        'Unspecified function type detected.\n');
                end
                
            end
            
            if nargin > 2
                obj.auxdata = auxdata;
            end
                
            %| @note 'feval' runs faster than function handle?
            
            %             % check if the function body exists
            %             assert(exist(obj.name,'file')==3 || ...
            %                 exist(obj.name,'file')==2,...
            %                 ['The user-defined function %s is not defined.\n',...
            %                 'Unable to construct the NLP function object.\n'],...
            %                 obj.name);
            
            
            % create function handle
            %             if isempty(obj.auxdata)
            %                 % create function handle without extra arguments
            %                 obj.value = str2func(strcat('@(x)',obj.name,'(x)'));
            %             else
            %                 % check the size
            %                 [nr,nc] = size(obj.auxdata);
            %                 assert(nr==1 || nc==1, ...
            %                     'The auxdata must be an 1-dimensional vector of constants.\n');
            %
            %                 % convert to a row vector
            %                 if nr~= 1 % if auxdata is a column vector
            %                     obj.auxdata = transpose(obj.auxdata);
            %                 end
            %
            %                 % convert to a string of constant numbers
            %                 s = mat2str(obj.auxdata);
            %
            %                 % create the function handle
            %                 obj.value = str2func(strcat('@(x)',obj.name,'(x,',s,')'));
            %
            %
            %
            %             end
                
                
        end
        
        
        function obj = setDependent(obj, depvars)
            % This function sets the dependent variables of the function
            %
            % Each cell may contains an array of NlpVariable objects. After
            % configuration, the funcion will be evaluated using typical
            % values of dependent variables. This process first checks if
            % the given function has been defined, and also determines the
            % dimension of the function
            %
            % Parameters:
            %  depvars: a cell array of dependent variables @type
            %  NlpVariables
            
            assert(iscell(depvars),...
                'NlpFunction:setDependentError',...
                'The list of dependent variables must be a cell array.\n');
            
            assert(all(cellfun(@(x)isa(x,'NlpVariable'),depvars)),...
                'NlpFunction:incorrectDataType',...
                'Each cell must consists of a single or an array of NlpVariable objects.\n');
            
            
            % catcate cell array into a single-dimensional NlpVariable
            % array
            obj.dep_vars = vertcat(depvars{:});
            
            
            % evaluate the function using typical values of dependent
            % variables
            x0 = vertcat(obj.dep_vars(:).x0);           
           
            if isempty(obj.auxdata)
                f_value = feval(obj.name, x0);
            else
                f_value = feval(obj.name, x0, obj.auxdata{:});
            end
            % get the dimension of the function
            obj.dimension = length(f_value);
            
            % store the dependent indices for quick access
            obj.dep_indices = vertcat(obj.dep_vars.indices);
            
            % default sparsity pattern of the (full) Jacobian matrix
            dimDeps = sum([obj.dep_vars.dimension]);
            obj = setJacobianPattern(obj, ones(obj.dimension, dimDeps), 'MatrixForm');
            
        end
        
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
            
            dimDeps = sum([obj.dep_vars.dimension]);
            
            switch sp_form
                case 'MatrixForm'
                    
                    % check the dimension
                    [m, n] = size(jac_sp);
                    
                    assert(m==obj.dimension && n==dimDeps,...
                        'NlpFunction:wrongDimension',...
                        ['The size of the Jacobian matrix is incorrect.\n',...
                        'It must be a %d x %d matrix.\n'], obj.dimension, dimDeps);
                    
                    [rows, cols] = find(jac_sp);
                    
                    obj.jac_nz_pattern.rows = rows;
                    obj.jac_nz_pattern.cols = cols;
                    
                    
                case 'IndexForm'
                    
                    % check if the maximum index exceeds the size of the
                    % function or dependent variabbles
                    m = max(jac_sp(:,1)); % the maximum row index
                    n = max(jac_sp(:,2)); % the maximum column index
                    
                    assert(m <= obj.dimension && n <= dimDeps,...
                        'NlpFunction:maxIndex',...
                        'The maximum non-zero index exceeds the size of the Jacobian matrix.\n');
                    
                    obj.jac_nz_pattern.rows = jac_sp(:,1);
                    obj.jac_nz_pattern.cols = jac_sp(:,2);
                    
                    
                otherwise
                    error('NlpFunction:incorrectForm',...
                        ['Unspecified form of the sparsity pattern.\n'...
                        'Please use either ''MatrixForm'' or ''IndexForm''.\n']);
            end
            
            obj.nnz_jac = length(obj.jac_nz_pattern.rows);
        end
        
        function obj = setJacobianFunction(obj, func_name)
            % This function specify the function (name) that calculates the
            % Jacobian matrix of the function
            
            obj.jac_func = func_name;
            
            % test function
            x0 = vertcat(obj.dep_vars(:).x0);
            
            if isempty(obj.auxdata)
                j_value = feval(obj.jac_func, x0);
            else
                j_value = feval(obj.jac_func, x0, obj.auxdata{:});
            end
            
            %| @todo check if it is valid?
        end
        
        
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
            
            dimDeps = sum([obj.dep_vars.dimension]);
            
            if isempty(hes_sp)
                obj.type = NlpFunction.LINEAR;
                obj.hess_nz_pattern.rows = [];
                obj.hess_nz_pattern.cols = [];
            else
            
                switch sp_form
                    case 'MatrixForm'
                        
                        [m, n, n_mat] = size(hes_sp);
                        
                        
                        assert(n_mat == obj.dimension && m==dimDeps && n==dimDeps,...
                            'NlpFunction:wrongDimension',...
                            ['The size of the Hessian matrix is incorrect.\n',...
                            'It must be a %d x %d x %d matrix.\n'], ...
                            dimDeps, dimDeps, obj.dimension);
                        
                        % check the dimension
                        sp_rows = cell(n_mat,1);
                        sp_cols = cell(n_mat,1);
                        for i=1:n_mat
                            [sp_rows{i}, sp_cols{i}] = find(hes_sp(:,:,i));
                        end
                        obj.hess_nz_pattern.rows = vertcat(sp_rows{:});
                        obj.hess_nz_pattern.cols = vertcat(sp_cols{:});
                        
                        
                    case 'IndexForm'
                        
                        % check if the maximum index exceeds the size of the
                        % function or dependent variabbles
                        m = max(hes_sp(:,1)); % the maximum row index
                        n = max(hes_sp(:,2)); % the maximum column index
                        
                        assert(m <= dimDeps && n <= dimDeps,...
                            'NlpFunction:wrongDimension',...
                            'The size of the Hessian matrix is incorrect.\n');
                        
                        obj.hess_nz_pattern.rows = hes_sp(:,1);
                        obj.hess_nz_pattern.cols = hes_sp(:,2);
                        
                        
                    otherwise
                        error('Unspecified form of the sparsity pattern.\n');
                end
            end
            obj.nnz_hess = length(obj.hess_nz_pattern.rows);
        end
        
        function obj = setHessianFunction(obj, func_name)
            % This function specify the function (name) that calculates the
            % Jacobian matrix of the function
            
            obj.hess_func = func_name;
            
            % test function
            x0 = vertcat(obj.dep_vars(:).x0);
            
            if isempty(obj.auxdata)
                h_value = feval(obj.hess_func, x0, ones(obj.dimension,1));
            else
                h_value = feval(obj.hess_func, x0, ones(obj.dimension,1), obj.auxdata{:});
            end
            
            %| @todo check if it is valid?
        end
        
        function obj = setBoundaryValue(obj, cl, cu)
            % set the upper/lower boundary values of the function if they
            % exist
            %
            % Parameters:
            %  cl: the lower boundary
            %  cu: the upper boundary
            
            if nargin > 1
                if isscalar(cl)
                    obj.cl = cl*ones(obj.dimension,1);
                end
            end
            
            if nargin > 2
                if isscalar(cu)
                    obj.cu = cu*ones(obj.dimension,1);
                end            
            end
            
        end
        
        
        function obj = appendTo(obj, funcs)
            % Appends the new NlpFunction 'funcs' to the existing
            % NlpFunction array
            %
            % Parameters:
            %  obj: an array of NlpVariable objects @type NlpVariable
            %  funcs: a new functions to be appended to @type NlpVariable
            
            assert(isa(funcs,'NlpFunction'),...
                'NlpVariable:incorrectDataType',...
                'The functions that append to the array must be a NlpFunction object.\n');
            
            last_entry = numel(obj);
            
            num_funcs = numel(funcs);
            
            obj(last_entry+1:last_entry+num_funcs) = funcs;
            
        end
        
%         function obj = genIndices(obj, fun_index_offset, jac_index_offset, hes_index_offset)
%             % Generates indinces of each function if the input is an array
%             % of NlpFunction objects.
%             %
%             % Parameters:
%             %  index0: the offset of the starting index of the variable
%             %  array indices @type integer
%             
%             % get the size of object array
%             num_obj = numel(obj);
%             
%             % If an offset is not specified, set it to zero.
%             if (nargin < 2)  
%                 fun_index_offset = 0;
%             end
%             if (nargin < 3)
%                 jac_index_offset = 0;
%             end
%             if (nargin < 4)
%                 hes_index_offset = 0;
%             end
%             
%             
%             for i = 1:num_obj
%                 % set the index
%                 obj(i).fun_indices = fun_index_offset + cumsum(ones(1,obj(i).dimension));
%                         
%                 obj(i).nnz_jac_indices = jac_index_offset + cumsum(ones(1,obj(i).nnz_jac));
%                 
%                 obj(i).nnz_hess_indices = hes_index_offset + cumsum(ones(1,obj(i).nnz_hess));
%                 
%                 
%                 % increments (updates) offset
%                 fun_index_offset = fun_index_offset + obj(i).dimension;
%                 
%                 jac_index_offset = jac_index_offset + obj(i).nnz_jac;
%                 
%                 hes_index_offset = hes_index_offset + obj(i).nnz_hess;
%             end
%         end
%         

    end
    
end