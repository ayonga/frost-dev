classdef SymFunction < handle
    % This class provides an interface to a symbolic expression (or
    % function) represented in Mathematica kernal. 
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess = protected, GetAccess = protected)
        % An identification name of the function
        %
        % @type char
        name
        
        % The symbolic expression of the function in Mathematica
        %
        % @type SymExpression
        expr
        
        % The symbolic name of the dependent variables in Mathematica
        %
        % @type SymVariable
        vars
        
        % The symbolic name of the auxilary parameters in Mathematica
        %
        % @type SymVariable
        params
        
        
        % The export options
        %
        % @struct
        options
        
    end
    
    properties (SetAccess=private, GetAccess=public)
        % File names of the functions.
        %
        % Each field of ''Funcs'' specifies the name of a function that
        % used for a certain computation of the function.
        %
        % Required fields of funcs:
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
        funcs
    end
    
    
    methods
        
        function obj = SymFunction(name, expr, vars, params)
            % The class constructor function.
            %
            % Parameters:       
            %  name: the name of the function. @type char   
            %  expr: the symbolic expression of the function @type
            %  char
            %  vars: the symbolic representation of variables in the
            %  expression @type cell
            %  params: the symbolic representation of parameters in the
            %  expression @type cell
           
            
            
            % validate name string
            assert(isempty(regexp(name, '\W', 'once')),...
                'SymFunction:invalidNameStr', ...
                'Invalid name string, can NOT contain special characters.');
            assert(ischar(name), 'The name must be a char vector.');
            obj.name = name;
            
            % validate symbolic expression
            if nargin > 1
                obj.expr =  SymExpression(expr);
            end
            
            if nargin > 2
                if ~iscell(vars), vars = {vars}; end
                assert(all(cellfun(@(x)isa(x,'SymVariable'), vars)),...
                    'SymFunction:invalidVariables', ...
                    'The dependent variables must be valid SymVariable objects.');
                
                obj.vars = vars;
            end
            
            if nargin > 3
                if ~iscell(params), params = {params}; end
                assert(all(cellfun(@(x)isa(x,'SymVariable'), params)),...
                    'SymFunction:invalidVariables', ...
                    'The dependent variables must be valid SymVariable objects.');
                
                obj.params = params;
            end
            
            
        end
        
        
        
        
    end
    
    
    %% dependent properties
    properties (Dependent)
        
       
        
        
        % File names of the functions. 
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
    end
    
    methods
        
        
        function Funcs = get.Funcs(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            Funcs = struct(...
                'Func',['f_',obj.Name],...
                'Jac',['J_',obj.Name],...
                'JacStruct',['Js_',obj.Name],...
                'Hess',['H_',obj.Name],...
                'HessStruct',['Hs_',obj.Name]);
        end
    end
    
    
    % methods defined in external files
    methods
        
        status = export(obj, export_path, do_build, derivative_level);
        
    end
end