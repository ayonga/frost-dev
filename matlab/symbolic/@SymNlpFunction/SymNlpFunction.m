classdef SymNlpFunction < handle
    % This class represents a vector symbolic expression for a NLP
    % constraints or objective function. 
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess = protected, GetAccess = public)
        % An identification name of the function
        %
        % @type char
        Name
        
        % The symbolic expression of the function in Mathematica
        %
        % @type SymExpression
        Expr
        
        % The symbolic name of the dependent variables in Mathematica
        %
        % @type SymVariable
        Vars
        
        % The symbolic name of the auxilary parameters in Mathematica
        %
        % @type SymVariable
        Params
        
        
        % The status flags of the SymNlpFunction
        %
        % These flags stores the status of assignment, export and
        % compilation of the associated symbolic function.
        %
        % @type struct
        IsCompiled
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
        Funcs
    end
    
    
    methods
        
        function obj = SymNlpFunction(name, expr, vars, params)
            % The class constructor function.
            %
            % Parameters:       
            %  name: the name of the function. @type char   
            %  expr: the symbolic expression of the function 
            %  @type char
            %  vars: the symbolic representation of variables in the
            %  expression @type cell
            %  params: the symbolic representation of parameters in the
            %  expression @type cell
           
            if nargin == 0 
                return;
            end
            
            
            % validate name string
            assert(isempty(regexp(name, '\W', 'once')),...
                'SymNlpFunction:invalidNameStr', ...
                'Invalid name string, can NOT contain special characters.');
            assert(isvarname(name), 'The name must be a char vector.');
            obj.Name = name;
            
            obj.Funcs = struct(...
                'Func', ['f_' obj.Name], ...
                'Jac', ['J_' obj.Name],...
                'JacStruct', ['Js_' obj.Name],...
                'Hess', ['H_' obj.Name],...
                'HessStruct', ['Hs_' obj.Name]);
            
            % validate symbolic expression
            if nargin > 1
                obj.Expr =  tovector(SymExpression(expr));
            else
                obj.Expr = SymExpression('{}');
            end
            
            if nargin > 2
                if ~iscell(vars), vars = {vars}; end
                assert(all(cellfun(@(x)isa(x,'SymVariable'), vars)),...
                    'SymNlpFunction:invalidVariables', ...
                    'The dependent variables must be valid SymVariable objects.');
                vars = cellfun(@(x)flatten(x), vars,'UniformOutput',false);
                obj.Vars = tovector([vars{:}]);
            else
                obj.Vars = [];
            end
            
            if nargin > 3
                if ~iscell(params), params = {params}; end
                assert(all(cellfun(@(x)isa(x,'SymVariable'), params)),...
                    'SymNlpFunction:invalidVariables', ...
                    'The dependent variables must be valid SymVariable objects.');
                params = cellfun(@(x)flatten(x), params,'UniformOutput',false);
                obj.Params = tovector([params{:}]);
            else
                obj.Params = [];
            end
            
            obj.IsCompiled = false;
            
        end
        
        
        
        
    end
    
    
   
    
    
    
   
    
    
    % methods defined in external files
    methods
        
        export(obj, export_path, derivative_level, do_build, reload);
        
    end
end