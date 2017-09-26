classdef SymFunction < SymExpression
    % This class wraps a symbolic expression with additional information
    % for the convenience of compiling and exporting the symbolic
    % expression to a C/C++ source files.
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
        
                
        % The symbolic representation of the dependent variables 
        %
        % @type SymVariable
        Vars
        
        % The symbolic representation of the constant parameters 
        %
        % @type SymVariable
        Params
        
        
        
    end
    
    
    properties (SetAccess = protected, GetAccess = public)
        % The status flags of the SymFunction
        %
        % These flags stores the status of assignment, export and
        % compilation of the associated symbolic function.
        %
        % @type struct
        Status
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
        
        function obj = SymFunction(name, expr, vars, params)
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
           
            
            obj = obj@SymExpression(expr);
            
            
            
            % validate name string
            assert(isvarname(name), 'The name must be a char vector.');
            obj.Name = name;
            
            obj.Funcs = struct(...
                'Jac', ['J_' obj.Name],...
                'JacStruct', ['Js_' obj.Name],...
                'Hess', ['H_' obj.Name],...
                'HessStruct', ['Hs_' obj.Name]);
            
            
            
            if nargin > 2
                if ~isempty(vars)                    
                    if ~iscell(vars), vars = {vars}; end
                    assert(all(cellfun(@(x)isa(x,'SymVariable'), vars)),...
                        'SymFunction:invalidVariables', ...
                        'The dependent variables must be valid SymVariable objects.');
                    obj.Vars = vars;
                else
                    obj.Vars = {};
                end
                % vars = cellfun(@(x)flatten(x), vars,'UniformOutput',false);
                % obj.Vars = tovector([vars{:}]);
            else
                obj.Vars = {};
            end
            
            if nargin > 3
                if ~isempty(params)
                    if ~iscell(params), params = {params}; end
                    assert(all(cellfun(@(x)isa(x,'SymVariable'), params)),...
                        'SymFunction:invalidVariables', ...
                        'The dependent variables must be valid SymVariable objects.');
                    obj.Params = params;
                else
                    obj.Params = {};
                end
                % params = cellfun(@(x)flatten(x), params,'UniformOutput',false);
                % obj.Params = tovector([params{:}]);
            else
                obj.Params = {};
            end
            
            obj.Status = struct();
            obj.Status.FunctionExported = false;
            obj.Status.JacobianExported = false;
            obj.Status.HessianExported  = false;
            obj.Status.FunctionSaved    = false;
            obj.Status.FunctionLoaded   = false;
        end
        
        
        
        
    end
    
    
   
    
    
    
   
    
    
    % methods defined in external files
    methods
        
        
        f = export(obj, export_path, varargin);
        
        [J,Js] = exportJacobian(obj, export_path, varargin);
        
        [H,Hs] = exportHessian(obj, export_path, varargin);
        
        file = save(obj, export_path, varargin);
        
        obj = load(obj, file_path);
    end
end
