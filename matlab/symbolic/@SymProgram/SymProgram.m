classdef SymProgram < handle 
    % SymProgram is a symbolic operator that represents a symbolic
    % function in the Mathematica Kernal.
    %
    %
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (Access = protected)        
        % An array of dependent variables
        %
        % @type SymVariable
        vars
    end
    
    properties (Access=protected)
        % The body (or formula) of the symbolic expression
        %
        % @type char
        f
    end
    
    properties (GetAccess=protected, SetAccess=protected)
        % The symbol that represents the symbolic expression
        %
        % @type char
        s
    end
    
    methods
        
        function obj = SymProgram(x, vars, description)
            % The class constructor function.
            %
            % Parameters:  
            % x: the symbolic expression statement @type char
            % vars: the array of dependent variables @type SymVariable
           
            
            
            if isnumeric(x) 
                x = SymExpression(x);
            elseif ischar(x)
                x = SymExpression(x);
            elseif ~isa(x,'SymExpression') 
                error('First input must be a symbolic expression.');
            end 
            
            
            
            
            
            
            
            
            
            obj.s = eval_math('Unique[symfun$]');
            obj.f = x.f;
            
            if nargin > 1
                obj.vars = SymFunction.validateArgNames(vars);
                
                cvars = cellfun(@(x)x.f,privToCell(obj.vars),'UniformOutput',false);
                svars = sprintf('%s_, ',cvars{:});
                svars(end-1:end)=[];
                fstr = [obj.s '[' svars ']'];
            else
                fstr = [obj.s '[]'];
            end
            
            % evaluate the operation in Mathematica and return the
            % expression string
            eval_math([fstr ':=' obj.f ';']);
            
            
            if nargin > 2
                eval_math([obj.s '::usage=' str2mathstr(description) ';']);
            end
        end
        
        
        function display(obj, namestr) %#ok<INUSD,DISPLAY>
            % Display the symbolic expression
            
            eval_math(['?' obj.s])
        end
        
        function delete(obj) %#ok<INUSD>
            % object destruction function
            %             if ~isempty(obj.vars)
            %
            %                 cvars = cellfun(@(x)x.s,privToCell(obj.vars),'UniformOutput',false);
            %                 svars = sprintf('%s_, ',cvars{:});
            %                 svars(end-1:end)=[];
            %                 fstr = [obj.s '[' svars ']'];
            %             else
            %                 fstr = [obj.s '[]'];
            %             end
            %             eval_math([fstr '=.;']);
        end
        
        
        function y = argnames(x)
            %ARGNAMES   Symbolic function input variables
            %   ARGNAMES(F) returns a sym array [X1, X2, ... ] of symbolic
            %   variables for F(X1, X2, ...).
            %
            %   Example
            %    syms f(x,y)
            %    argnames(f)    % returns [x, y]
            %
            %   See also SYMFUN/FORMULA
            y = x.vars;
        end

        
        

        function varargout = subsindex(varargin)  %#ok<STOUT>
            error('Indexing values must be positive integers, logicals or symbolic variables.');
        end
        
        function varargout = end(varargin) %#ok<STOUT>
            error('END is not a valid input for symbolic functions.');
        end
    end
    
    
    
    
    % methods defined in external files
    methods (Hidden, Static)
        
        function args = validateArgNames(args)
            %validateArgNames   When creating symfuns make sure the arguments are simple sym object names
            % do not allow zero arguments
            if ~isequal(class(args),'SymVariable') || ~builtin('isvector', args) || isempty(args)
                error('Third input must be a scalar or vector of unique symbolic variables.');
            end
            args2 = unique(args);
            if length(args2) ~= length(args)
                error('Third input must be a scalar or vector of unique symbolic variables.');
            end
            
        end
        
    end
end