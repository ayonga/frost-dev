classdef NlpFunctionSum < NlpFunction
    % This class provides a particular NLP function that is the sum of
    % multiple NlpFunction objects. For instance, the cost function,
    % etc.
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        % The sub NLP functions
        %
        % @type NlpFunction
        Dependents
    end
    
    
    methods 
        function obj = NlpFunctionSum(varargin)
            % The class constructor function.
            %
            % @copydoc NlpFunction.NlpFunction
            
           
            % call superclass constructor
            obj = obj@NlpFunction(varargin{:});
            
            if nargin == 0
                return;
            end
            
            argin = struct(varargin{:});
            if isfield(argin, 'DependentFuncs')
                obj = setDependentFunction(obj, argin.DependentFuncs);
            end
        end
       
        function obj = setDependentFunction(obj, deps)
            % Sets dependent objects of the Nlp Function
            %
            % Parameters:
            % deps: dependent objects  @type NlpFunction
            
            
            if ~isa(deps,'NlpFunction')
                error('NlpFunctionSum:invalidObject', ...
                    'There exist non-NlpFunction objects in the dependent functions list.');
            end
            
            obj.Dependents = deps(:);
        end
        
        function obj = setFuncIndices(obj, index)
            % Sets indices of the Nlp Function
            %
            % Parameters:
            %  index: the indices of the function @type integer
            
            assert(length(index) == obj.Dimension, ...
                'The length of the variable indices must be equal to the dimension of the NlpVariable object.');
            
            obj.Dependents = arrayfun(@(x) setFuncIndices(x, index), ...
                obj.Dependents, 'UniformOutput', false);
            
            obj.FuncIndices = index;
        end
        
        
        
       
        function deps = getDepObject(obj)
            % Returns the object of the dependent function
            %
            % Return values: 
            % deps: the dependent objects 
            
            deps = arrayfun(@(x)getDepObject(x), obj.Dependents,...
                'UniformOutput', false);
            deps = vertcat(deps{:});
        end
    end
    
    
end