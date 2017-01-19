classdef NlpVariable < handle
    % This class provides a data structure for NLP optimization variables.
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
    
    
    properties (SetAccess = protected)
        % A string that specifies the name of the optimization variable
        %
        % @type char
        Name
        
        % The dimension the optimization variable
        %
        % When we define a optimization variable, we assume that it
        % represnts a vector of variable that belongs to a particular
        % group. For example, the joint configurations 'q' and control
        % inputs 'u'. The 'dimension' specifies the length of this vector.
        %
        % @type integer
        Dimension
        
        % The typical value of the variable
        %
        % You can specify a typical value for the variable explicity. If
        % not given, this value will be determined by the upper/lower
        % boundary of the variable. If both upper/lower boundary values are
        % infinity, then we set the typical value as zeros. If one of the
        % upper/lower boundary values is infinity, then the typical value
        % will be the non-infinity boundary value. Otherwise, the typical
        % value will be the middle point of the two boundary values.
        %
        % @type colvec
        InitialValue
        
        % The lower limit of the optimization variable
        %
        % @type colvec
        LowerBound
        
        % The upper limit of the optimization variable
        %
        % @type colvec
        UpperBound
        
        % The index of the current variable in an array of NlpVariable
        % objects
        %
        % @type colvec
        Indices
    end
    
    
    methods
        function obj = NlpVariable(varargin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %   Name: name of the variable @type char
            %   Dimension: dimension of the variable @type integer
            %   lb: lower limit @type colvec
            %   ub: upper limit @type colvec
            %   x0: a typical value of the variable @type colvec
            
            
            % if no input argument, create an empty object
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
            
            
            
            % set the dimension to be 1 by default
            if isfield(argin, 'Dimension')
                obj = setDimension(obj, argin.Dimension);
            else
                obj = setDimension(obj, 1);
            end
            
            % set boundary values
            if isfield(argin, 'lb')
                obj =  setBoundary(obj, argin.lb, []);
            else
                obj =  setBoundary(obj, -inf, []);
            end
            
            if isfield(argin, 'ub')
                obj =  setBoundary(obj, [], argin.ub);
            else
                obj =  setBoundary(obj, [], inf);
            end
            
            % set typical initial value
            if isfield(argin, 'x0')
                obj = setInitialValue(obj, argin.x0);
            else
                obj = setInitialValue(obj);
            end
        end
        
        
        
        
        
    end
    
    %% methods defined in external files
    methods
        obj = genIndices(obj, index_offset);
        
        obj = appendTo(obj, vars);
        
        obj = setBoundary(obj, lowerbound, upperbound);
        
        obj = setInitialValue(obj, x);
        
        obj = setName(obj, name);
        
        obj = setDimension(obj, dim);
    end
end