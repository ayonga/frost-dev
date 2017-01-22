classdef SymNlpFunction < NlpFunction
    % This class provides a particular type of NlpFunction object that uses
    % the Mathematica symbolic packages.
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties 
        
        % The symbolic expression of the function in Mathematica
        %
        % @type char
        Expression
        
        % The symbolic name of the dependent variables in Mathematica
        %
        % @type char
        DepSymbols
        
        % The symbolic name of the auxilary parameters in Mathematica
        %
        % @type char
        ParSymbols
    end
    
    properties (Dependent)
        % A actual symbol that represents the symbolic expression of the
        % function in Mathematica.
        %
        % @type char
        Symbols
    end
    
    methods
        
        function obj = SymNlpFunction(varargin)
            % The class constructor function.
            %
            % @copydoc NlpFunction.NlpFunction
            
           
            % call superclass constructor
            obj = obj@NlpFunction(varargin{:});
            
            if nargin == 0
                return;
            end
            
            argin = struct(varargin{:});
            if isfield(argin, 'Expression')
                obj.Expression = argin.Expression;
            end
        end
        
        function obj = set.Expression(obj, expr)
            
            % validate symbolic expressions
            if isempty(regexp(expr, '_', 'once'))
                obj.Expression = expr;
            else
                err_msg = 'The expression CANNOT contain ''_''.\n %s';                
                error('SymNlpFunction:invalidExpr', err_msg, expr);
            end
            
        end
        
        
        function Symbols = get.Symbols(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            Symbols = ['$f["',obj.Name,'"]'];
        end
    end
    
    methods
        
        status = export(obj, export_path, do_build, derivative_level);
        
        obj = configure(obj, derivative_level);
    end
end