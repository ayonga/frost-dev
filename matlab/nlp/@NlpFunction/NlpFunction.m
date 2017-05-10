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
        
        
        % An array of dependent NLP variables
        %
        % @type NlpVariable
        DepVariables
                
        % An array of summand NlpFunctions that are to be summed up to get
        % the current NLP function
        %
        % @type NlpFunction
        SummandFunctions
        
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
        
        
        % File names of the external functions that computes the
        % function/Jacobian/Hessian of the object.
        %
        % Each field of ''Funcs'' specifies the name of a function that
        % used for a certain computation of the function.
        %
        % Required fields of Funcs:
        %   Func: a string of the function that computes the
        %   function value @type char
        %   Jac: a string of the function that computes the
        %   function Jacobian @type char
        %   JacStruct: a string of the function that computes the
        %   sparsity structure of function Jacobian @type char
        %   Hess: a string of the function that computes the
        %   function Hessian @type char
        %   HessStruct: a string of the function that computes the
        %   sparsity structure of function Hessian @type char
        % @type struct
        Funcs
        
        
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
        % @type cell
        AuxData
        
        
        % The associated SymFunction object that specifies the symbolic
        % expression of the NlpFunction
        %
        % @type SymFunction
        SymFun
    end
    
    properties (SetAccess = protected, GetAccess = public)
        % The lower boundary values of the function
        %
        % @type colvec
        LowerBound
        
        % The upper boundary values of the function
        %
        % @type colvec
        UpperBound
        
        
        % It gives a quick access to the dimension of the function output
        % without actually evaluating the function
        %
        % @type integer @default 0
        Dimension = 0
    end
    
    
    methods
        function obj = NlpFunction(varargin)
            % The class constructor function.
            %
            % Parameters:       
            % varargin: variable nama-value pair input arguments, in detail:
            %  Name: the name of the function. @type char        
            %  Type: the type of the function. @type char
            %
            % 
            % @attention The 'auxdata' argument must be an 1-dimensional
            % vector of constants.
            
                        
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
                if ~isempty(argin.Type)
                    obj = setType(obj, argin.Type);
                end
            end            
            
            if isfield(argin, 'Dimension')
                if ~isempty(argin.Dimension)
                    obj = setDimension(obj, argin.Dimension);
                end
            end
            
            if isfield(argin, 'DepVariables')
                if ~isempty(argin.DepVariables)
                    obj = setDependentVariable(obj, argin.DepVariables);
                end
            end
            
            if isfield(argin, 'Funcs')
                if ~isempty(argin.Funcs)
                    obj = setFuncs(obj, argin.Funcs);
                end
            end
            
            if isfield(argin, 'SymFun')
                if isa(argin.SymFun,'SymFunction')
                    obj = setSymFun(obj, argin.SymFun);
                end                
            end
            
            
            % set boundary values
            if all(isfield(argin, {'ub','lb'}))
                obj =  setBoundary(obj, argin.lb, argin.ub);
            elseif isfield(argin, 'lb')
                obj =  setBoundary(obj, argin.lb, inf);
            elseif isfield(argin, 'ub')
                obj =  setBoundary(obj, -inf, argin.ub);
            else
                obj =  setBoundary(obj, -inf, inf);
            end
            
            
            if isfield(argin, 'AuxData')
                if ~isempty(argin.AuxData)
                    obj = setAuxdata(obj, argin.AuxData);
                end
            end
            
            if isfield(argin, 'Summand')
                if ~isempty(argin.Summand)
                    obj = setSummands(obj, argin.Summand);
                end
            end
        end
        
        function funcs = getSummands(obj)
            % Returns the object of the dependent function
            %
            % For most of the function object, the dependent object is
            % itself.
            %
            % Return values: 
            % funcs: the summand function objects @type NlpFunction
            
            if isempty(obj.SummandFunctions)
                funcs = obj;
            else
                funcs = arrayfun(@(x)getSummands(x), obj.SummandFunctions,...
                    'UniformOutput', false);
                funcs = vertcat(funcs{:});
            end
            
        end

        function obj = setSummands(obj, summands)
            % Sets dependent objects of the Nlp Function
            %
            % Parameters:
            % summands: the summand function objects @type NlpFunction
            
            
            if ~isa(summands,'NlpFunction')
                error('NlpFunctionSum:invalidObject', ...
                    'There exist non-NlpFunction objects in the dependent functions list.');
            end
            
            obj.SummandFunctions = summands(:);
        end
        
        function indices = getDepIndices(obj)
            % Returns the indices of the dependent variables
            %
            % Return values:
            % indices: the indices of dependent variables @type colvec
            indices = {obj.DepVariables.Indices};
        end
        
        
        
    end
    
    
    
    
    
    
    %% methods defined in external files
    methods
    
        obj = setName(obj, name);
        
        obj = setType(obj, type);
        
        obj = setAuxdata(obj, auxdata);
        
        obj = setJacobianPattern(obj, jac_sp, sp_form);
        
        
        obj = setHessianPattern(obj, hes_sp, sp_form);
        
        
        obj = setDependentVariable(obj, depvars);
        
        obj = setBoundary(obj, lowerbound, upperbound);
        
        obj = updateProp(obj, varargin);
        
        val = checkFuncs(obj, x, derivative_level);
        
        obj = setDimension(obj, dim);
        
        obj = setFuncIndices(obj, index);
        
        obj = setFuncs(obj, funcs);
        
        obj = setSymFun(obj, symfun);
        
    end
end
