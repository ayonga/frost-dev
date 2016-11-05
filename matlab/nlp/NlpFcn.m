classdef NlpFcn
    % This class provides a data structure for a optimization function.
    % This function could be either a constraint or a objective function of
    % the problem.
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties(Dependent)
        % This property specifies whether the function is the linear
        % function of dependent variables
        %
        % @type logical
        is_linear
    end
    
    methods
        function is_linear = get.is_linear(obj)
            % The 'get' method of the dependent variable: 'is_linear'.
            %
            % @note If the Hessian function is provided (i.e., 'hess' being
            % nonempty) but all elements in the Hessian matrix is zero
            % (i.e., 'hess_struct' being empty), then the function is a
            % linear function of the dependent variables.
            
            if isempty(obj.hess_struct) && ~isempty(obj.hess)
                is_linear = true;
            else
                is_linear = false;
            end
        end
    end
    
    properties
        % An identification of the object
        %
        % @type char
        name
        
        % It gives a quick access to the dimension of the function output
        % without actually evaluating the function
        dims
        
        
        
        % Stores the indexing information of the dependent variables
        %
        % @type colvec
        deps
        
        % Stores the indices of the non-zero elements in the first-order
        % jacobian
        %
        % @type colvec
        j_index
        
        % Stores the indices of the non-zero elements in the Hessian matrix
        % of the Lagrangian
        %
        % @type colvec
        h_index
        
        % A function handle points to the actual function that computes the
        % cost
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type function_handle
        f
        
        % A function handle points to the actual function that computes the
        % gradient vector of the cost
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type function_handle
        jac
        
        % A two-vector structure that specifies the non-zero structure of
        % the first order Jacobian of the function with respect to the
        % dependent variables. The first vector determines the row indices
        % of the all non-zero elements in the Jacobian matrix, and the
        % second vector determines the colomn indices of the all non-zero
        % elements in the Jacobian matrix. For the gradient of the cost
        % function, the first vector should consists of all '1's.
        %
        % @see sparsematrix 
        % 
        % @type struct
        jac_struct
        
        
        % A function handle points to the actual function that computes the
        % Hessian matrix of the function
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type function_handle
        hess
        
        % A two-vector structure that specifies the non-zero structure of
        % the second order Hessian of the Lagrangian function with respect
        % to the dependent variables. The first vector determines the row
        % indices of the all non-zero elements in the Hessian matrix, and
        % the second vector determines the colomn indices of the all
        % non-zero elements in the Hessian matrix.
        %
        % @see sparsematrix 
        % 
        % @type struct
        hess_struct
        
        % The number of nonzero entries in the Jacobian matrix
        %
        % @type integer
        nnzJac
        
        
        
        % The number of nonzero entries in the constraints portion of the
        % Hessian
        % 
        % @type integer
        nnzHess
    end
    
        
    methods
        function obj = NlpFcn(name, dimension, varargin)
            % The class constructor function.
            %
            % Parameters:
            % name: the name of the function. @type char
            % dimension: the dimension of the function @type integer
            % varargin: variable input argument. In detail
            %  extra: a list of extra constant arguments. @type rowvec
            %  withHessian: a param-value pair indicates whether Hessian
            %  functions are provided or not @logical
            %
            % @attention The 'extra' argument must be constant.
            
            p = inputParser;
            p.addRequired('name',@ischar);
            p.addRequired('dimension', @isnumeric);
            p.addOptional('extra',[],@isnumeric);
            p.addParameter('withHessian',false,@islogical);
            
            p.parse(name, dimension, varargin{:});
            name = p.Results.name;
            extra = p.Results.extra;
            withHessian = p.Results.withHessian;
            
            obj.name = name;
            obj.dims = p.Results.dimension;
            
            fcn_filename = strcat('f_',name);
            jac_filename = strcat('J_',name);
            js_filename = strcat('Js_',name);
            assert(exist(fcn_filename,'file')==3 || ...
                exist(fcn_filename,'file')==2,...
                'The file could not be found: %s\n',...
                fcn_filename); % 3 - Mex-file
            assert(exist(jac_filename,'file')==3 || ...
                exist(jac_filename,'file')==2,...
                'The file could not be found: %s\n',...
                jac_filename); % 3 - Mex-file
            assert(exist(js_filename,'file')==3 || ...
                exist(js_filename,'file')==2,...
                'The file could not be found: %s\n',...
                js_filename); % 3 - Mex-file
            
            if withHessian
                hess_filename = strcat('H_',name);
                hs_filename = strcat('Hs_',name);
                assert(exist(hess_filename,'file')==3 || ...
                    exist(hess_filename,'file')==2,...
                    'The file could not be found: %s\n',...
                    hess_filename); % 3 - Mex-file
                assert(exist(hs_filename,'file')==3 || ...
                    exist(hs_filename,'file')==2,...
                    'The file could not be found: %s\n',...
                    hs_filename); % 3 - Mex-file
            end
            
            if ~isempty(extra)
                % first convert to a string of constant numbers
                s = mat2str(extra);
                
                
                
                obj.f = str2func(strcat('@(x)',fcn_filename,'(x,',s,')'));
                obj.jac = str2func(strcat('@(x)',jac_filename,'(x,',s,')'));
                
                Js_handle = str2func(strcat('@()',js_filename,'(0)'));
                
                if withHessian
                    obj.hess = str2func(strcat('@(x,sigma)',hess_filename,'(x,sigma,',s,')'));
                    Hs_handle = str2func(strcat('@()',hs_filename,'(0)'));
                end
            else
                obj.f = str2func(strcat('@(x)',fcn_filename,'(x)'));
                obj.jac = str2func(strcat('@(x)',jac_filename,'(x)'));
                
                Js_handle = str2func(strcat('@()',js_filename,'(0)'));
                
                if withHessian
                    obj.hess = str2func(strcat('@(x,sigma)',hess_filename,'(x,sigma)'));
                    Hs_handle = str2func(strcat('@()',hs_filename,'(0)'));
                end
            end
            
            
            
            obj.jac_struct = Js_handle();
            obj.nnzJac = size(obj.jac_struct,1);
            
            
            if withHessian
                obj.hess_struct = Hs_handle();
                if ~obj.is_linear
                    assert(isempty(find(obj.hess_struct(:,1)<obj.hess_struct(:,2), 1)),...
                        'The Hessian matrix is symmetric matrix, so only lower triangular entries are needed.\n');
                end
                obj.nnzHess = size(obj.hess_struct,1);
            end
            
        end
        
        function obj = setDependentIndices(obj, depIndices)
            % It sets the indexing information of the dependent variables
            %
            % Parameters:
            % deps: the dependent variables indices
            
            obj.deps = depIndices;
        end
        
        function obj = setJacIndices(obj, jIndex0)
            % It sets the indexing of the non-zero entries in the Jacobian
            % matrix
            %
            % Parameters:
            %  jIndex0: the starting index of the j_index @type integer
            
            
            obj.j_index = jIndex0 + cumsum(ones(obj.nnzJac,1));
            
            
        end
        
        function obj = setHessIndices(obj, hIndex0)
            % It sets the indexing of the non-zero entries in the Hessian
            % matrix
            %
            % Parameters:
            %  hIndex0: the starting index of the h_index @type integer
            
           
            
            obj.h_index = hIndex0 + cumsum(ones(obj.nnzHess,1));
            
            
        end
    end
    
end