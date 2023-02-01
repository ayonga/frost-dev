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
        
        
        % An array of dependent NLP variables
        %
        % @type NlpVariable
        DepVariables
        
        
        % It gives a quick access to the dimension of the function output
        % without actually evaluating the function
        %
        % @type integer @default 0
        Dimension 
        
        % An identification of the object
        %
        % @type char
        Name
    end
    
    properties (Dependent)
        
        % This property specifies whether the function is the linear
        % function of dependent variables
        %
        % @type logical
        Type
    end
        
    methods
        
        function type = get.Type(obj)
            
            if ~isempty(obj.SymFun)
                f = obj.SymFun;
                s = reshape(f.Vars{:},[],1);
                x = vertcat(s{:});
                jac = jacobian(f,x);
                if ~isempty(f.Params)
                    jac = subs(jac,f.Params,obj.AuxData);
                end
                
                if isempty(symvar(jac))% if jacobian consists of all constant (no symbolic variables)
                    type = 'Linear';
                else
                    type = 'Nonlinear';
                end
            else
                type = 'Nonlinear';
            end
        end
    end
    
    
    methods
        function obj = NlpFunction(func, depvars, props)
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
            
            arguments
                func = []
                depvars (:,1) NlpVariable = NlpVariable.empty()
                props.lb (:,1) double {mustBeReal,mustBeNonNan} = []
                props.ub (:,1) double {mustBeReal,mustBeNonNan} = []
                props.AuxData cell = {}
            end
                
                        
            % MATLAB suggests a class must support the no input argument
            % constructor syntax.
            %             if nargin == 0
            %                 return;
            %             end
            
            if ~isempty(func)
                switch class(func)
                    case 'SymFunction'
                        mustBeVector(func);
                        obj.Name = func.Name;
                        obj.Dimension = length(func);
                        obj.SymFun = func;
                        funcs_name = func.Funcs;
                        funcs_name.Func = func.Name;
                        obj.Funcs = funcs_name;
                    case 'struct'
                        mustBeValidVariableName(func.Name);
                        obj.Name = func.Name;
                        mustBeInteger(func.Dimension);
                        mustBePositive(func.Dimension);
                        mustBeScalarOrEmpty(func.Dimension);
                        obj.Dimension = func.Dimension;
                        funcs_name = rmfield(func,{'Name','Dimension'});
                        setFuncs(obj, funcs_name);
                    otherwise
                        error('The first argument must be a SymFunction object or a struct variable');
                end
                
            end
            
            
            if ~isempty(depvars)
                obj = setDependentVariable(obj, depvars);
            end
         
            
            
            
            props_cell = namedargs2cell(props);
            % set properties
            updateProp(obj, props_cell{:});
            
        end
        
       
        
        function indices = getDepIndices(obj, useStackedVariable)
            % Returns the indices of the dependent variables
            %
            % Return values:
            % indices: the indices of dependent variables @type colvec
            
            if useStackedVariable
                temp = reshape({obj.DepVariables.Indices},[],1);
                indices = vertcat(temp{:});
            else
                indices = {obj.DepVariables.Indices};
            end
        end
        
        
        
    end
    
    
    
    
    
    
    %% methods defined in external files
    methods
    
        
        obj = setAuxdata(obj, auxdata);
        
        obj = setJacobianPattern(obj, jac_sp, sp_form);
        
        
        obj = setHessianPattern(obj, hes_sp, sp_form);
        
        
        obj = setDependentVariable(obj, depvars);
        
        
        obj = updateProp(obj, props);
        
        val = checkFuncs(obj, x, derivative_level);
        
        
        obj = setFuncIndices(obj, index);
        
        obj = setFuncs(obj, funcs);
                
    end
end
