classdef SymNlpFunctionSum < NlpFunction
    % This class provides a particular NLP function that is the sum of
    % multiple SymNlpFunction objects
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        % The dependent functions
        %
        % @type SymNlpFunction
        Dependents
    end
    
    
    methods 
        function obj = SymNlpFunctionSum(varargin)
            % The class constructor function.
            %
            % @copydoc NlpFunction.NlpFunction
            
           
            % call superclass constructor
            obj = obj@NlpFunction(varargin{:});
            
            if nargin == 0
                return;
            end
            
            argin = struct(varargin{:});
            if isfield(argin, 'Dependents')
                obj.Dependents = argin.Dependents;
            end
        end
       
        function obj = set.Dependents(obj, deps)
            
            if ~iscell(deps)
                deps = {deps};
            end
            
            % validate dependent arguments
            check_object = @(x) ~isa(x,'SymNlpFunction');
            
            if any(cellfun(check_object,deps))
                error('SymNlpFunctionSum:invalidObject', ...
                    'There exist non-SymNlpFunctionSum objects in the dependent variable list.');
            end
            
            
            
            obj.Dependents = deps;
        end
        
        
        function status = export(obj, varargin)
            % Export the symbolic expression of sub-functions to C/C++ source
            % files and build them as MEX files.
           
            deps = obj.Dependents;
            % first compile dependent kinematics constraints
            cellfun(@(x) export(x, varargin{:}), deps);
        end
        
        function obj = configure(obj, derivative_level)
            % Configures the function handles and sparsity patterns of function
            % derivatives
            %
            %
            % Parameters:
            %  derivative_level: determines the level of derivatives to be exported
            %  (1, 2) @type double
            
            if nargin < 2
                derivative_level = 1;
            end
            
            deps = obj.Dependents;
            % first compile dependent kinematics constraints
            obj.Dependents = cellfun(@(x) configure(x, derivative_level), deps);
        end
    end
    
        
            
end