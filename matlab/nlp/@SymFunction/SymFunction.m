classdef SymFunction
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
    
    properties (SetAccess = protected, GetAccess = public)
        % An identification of the object
        %
        % @type char
        Name
        
        % The symbolic expression of the function in Mathematica
        %
        % @type char
        Expression
        
        % The symbolic name of the dependent variables in Mathematica
        %
        % @type cell
        DepSymbols
        
        % The symbolic name of the auxilary parameters in Mathematica
        %
        % @type cell
        ParSymbols
        
        % The symbolic commands must be evaluated prior to exporting the
        % symbolic NlpFunctions.
        %
        % @type char
        PreCommands
        
        % Description of the function
        %
        % @type string
        Description
    end
    
    
    
    methods
        
        function obj = SymFunction(varargin)
            % The class constructor function.
            %
            % Parameters:       
            % varargin: variable nama-value pair input arguments, in detail:
            %  Name: the name of the function. @type char   
            %  Expression: the symbolic expression of the function @type
            %  char
            %  DepSymbols: the symbolic representation of variables in the
            %  expression @type cell
            %  ParSymbols: the symbolic representation of constants in the
            %  expression @type cell
            %  PreCommands: a list of commands requires to be executed
            %  prior to the expression @type char
           
            
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
            
            if isfield(argin, 'Expression')
                obj = setExpression(obj, argin.Expression);
            end
            
            if isfield(argin, 'DepSymbols')
                obj = setDepSymbols(obj, argin.DepSymbols);
            end
            
            if isfield(argin, 'ParSymbols')
                obj = setParSymbols(obj, argin.ParSymbols);
            end
            
            if isfield(argin, 'PreCommands')
                obj = setPreCommands(obj, argin.PreCommands);
            end
        end
        
        function obj = setName(obj, name)
            % Specifies the name of the NLP function
            %
            % Parameters:
            % name: the name character @type char
            
            
            assert(ischar(name), 'The name must be a string.');
            
            % validate name string
            assert(isempty(regexp(name, '\W', 'once')),...
                'Kinematics:invalidNameStr', ...
                'Invalid name string, can NOT contain special characters.');
            
            obj.Name = name;
            
            
        end
        
        function obj = setExpression(obj, expr)
            
            % validate symbolic expressions
            if isempty(regexp(expr, '_', 'once'))
                obj.Expression = expr;
            else
                err_msg = 'The expression CANNOT contain ''_''.\n %s';                
                error('SymNlpFunction:invalidExpr', err_msg, expr);
            end
            
        end
        
        function obj = setDepSymbols(obj, symbols)
            
            % validate symbolic expressions
            if all(cellfun(@(x)isempty(regexp(x, '_', 'once')), symbols))
                obj.DepSymbols = symbols;
            else
                err_msg = 'The symbol CANNOT contain ''_''.\n';                
                error('SymNlpFunction:invalidExpr', err_msg);
            end
            
        end
        
        function obj = setParSymbols(obj, symbols)
            
            % validate symbolic expressions
            if all(cellfun(@(x)isempty(regexp(x, '_', 'once')), symbols))
                obj.ParSymbols = symbols;
            else
                err_msg = 'The symbol CANNOT contain ''_''.\n';                
                error('SymNlpFunction:invalidExpr', err_msg);
            end
            
        end
        
        function obj = setPreCommands(obj, cmd)
            
            % validate symbolic expressions
            if isempty(regexp(cmd, '_', 'once'))
                obj.PreCommands = cmd;
            else
                err_msg = 'The command CANNOT contain ''_''.\n';                
                error('SymNlpFunction:invalidExpr', err_msg);
            end
            
        end
        
        function obj = setDescription(obj, str)
           
            if ischar(str)
                obj.Description = string(str);
            elseif isstring(str)
                obj.Description = str;
            elseif iscellstr(str)
                obj.Description = string(str);
            end
        end
        
    end
    
    
    %% dependent properties
    properties (Dependent)
        
        % A actual symbol that represents the symbolic expressions in
        % Mathematica.
        %
        % @type char
        Symbol
        
        
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
        function symbol = get.Symbol(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            symbol = ['$f["',obj.Name,'"]'];
        end
        
        function Funcs = get.Funcs(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            Funcs = struct(...
                'Func',['f_',obj.Name],...
                'Jac',['J_',obj.Name],...
                'JacStruct',['J_',obj.Name],...
                'Hess',['H_',obj.Name],...
                'HessStruct',['Hs_',obj.Name]);
        end
    end
    
    
    % methods defined in external files
    methods
        
        status = export(obj, export_path, do_build, derivative_level);
        
    end
end