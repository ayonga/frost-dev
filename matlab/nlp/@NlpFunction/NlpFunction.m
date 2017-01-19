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
    
    
    properties (SetAccess = protected, GetAccess = public)
        
        % This property specifies whether the function is the linear
        % function of dependent variables
        %
        % @type logical
        Type
        
        % An identification of the object
        %
        % @type char
        Name
        
        % It gives a quick access to the dimension of the function output
        % without actually evaluating the function
        %
        % @type integer
        Dimension
        
        % An array of dependent NLP variables
        %
        % @type NlpVariable
        DepVariables
                
        % Stores the indices of all dependent variables in a vector
        %
        % @type colvec
        DepIndices
        
        % Stores the indices of the function
        %
        % @type colvec
        FuncIndices
        
        % Stores the indices of the non-zero elements in the first-order
        % jacobian
        %
        % @type colvec
        nnzJacIndices
        
        % Stores the indices of the non-zero elements in the Hessian matrix
        % of the Lagrangian
        %
        % @type colvec
        nnzHessIndices
        
        % The name of the function that computes the Jacobian of the
        % function
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type char
        JacFunc
        
        
        % The name of the function that computes the Jacobian of the
        % function
        %
        % Typically, this function is generated as a MEX function by
        % Mathematica symbolic engine. It can be also written as a matlab
        % function by the user.
        %
        % @type char
        HessFunc
        
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
        JacPattern        
        
        
        
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
        HessPattern
        
        % The number of nonzero entries in the Jacobian matrix
        %
        % @type integer
        nnzJac
        
        
        
        % The number of nonzero entries in the Hessian matrix
        % 
        % @type integer
        nnzHess
        
        
        % A constant array of auxiliary data that will be used to construct
        % the function handles
        %
        % @type matrix
        AuxData
        
        % The lower boundary values of the function
        %
        % @type colvec
        LowerBound
        
        % The upper boundary values of the function
        %
        % @type colvec
        UpperBound
        
    end
    
        
    methods
        function obj = NlpFunction(varargin)
            % The class constructor function.
            %
            % Parameters:       
            % varargin: variable nama-value pair input arguments, in detail:
            %  Name: the name of the function. @type char        
            %  Type: the type of the function. @type char
            %  AuxData: a row vector of constant arguments of the function.
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
            %             obj.Name = p.Results.name;
            %             obj.AuxData = p.Results.auxdata;
            
            % MATLAB suggests a class must support the no input argument
            % constructor syntax.
            if nargin == 0
                return;
            end
            
            
            argin = struct(varargin{:});
            % check name type
            if isfield(argin, 'Name')
                obj = setName(obj, argin.Name);
            else
                if ~isstruct(varargin{1})
                    error('The ''Name'' must be specified in the argument list.');
                else
                    error('The input structure must have a ''Name'' field');
                end
            end
            
            if isfield(argin, 'Type')
                obj = setType(obj, argin.Type);
            else 
                % by default, we consider all functions to be non-linear
                obj = setType(obj, 'Nonlinear');
            end
            
            
            if isfield(argin, 'AuxData')
                obj = setAuxdata(obj, argin.AuxData);
            end
                
            
                
                
        end
        
        

    end
    
    %% methods defined in external files
    methods
    
        obj = setName(obj, name);
        
        obj = setType(obj, type);
        
        obj = setAuxdata(obj, auxdata);
        
        obj = setJacobianPattern(obj, jac_sp, sp_form);
        
        obj = setJacobianFunction(obj, func_name);
        
        obj = setHessianPattern(obj, hes_sp, sp_form);
        
        obj = setHessianFunction(obj, func_name);
        
        obj = setDependent(obj, depvars);
        
        obj = setBoundaryValue(obj, cl, cu);
        
        obj = appendTo(obj, funcs);
        
    end
end