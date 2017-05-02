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
        % @type integer @default 0
        Dimension = 0;
        
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
            
            
            % update property values using the input arguments
            % load default values if not specified explicitly
            
            argin = struct(varargin{:});
            % check name type
            if isfield(argin, 'Name')
                assert(ischar(argin.Name), 'The name must be a string.');
            
                % validate name string
                assert(isempty(regexp(argin.Name, '\W', 'once')),...
                    'NlpVariable:invalidNameStr', ...
                    'Invalid name string, it CANNOT contain special characters.');
                
                obj.Name = argin.Name;
            else
                if ~isstruct(varargin{1})
                    error('The ''Name'' must be specified in the argument list.');
                else
                    error('The input structure must have a ''Name'' field');
                end
            end
            
            
            
            % set the dimension to be 1 by default
            if isfield(argin, 'Dimension')
                assert(isscalar(argin.Dimension) && argin.Dimension >=0 ...
                    && rem(argin.Dimension,1)==0 && isreal(argin.Dimension), ...
                    'The dimension must be a scalar positive value.');
                obj.Dimension = argin.Dimension;
            else
                if ~isstruct(varargin{1})
                    error('The ''Dimension'' must be specified in the argument list.');
                else
                    error('The input structure must have a ''Dimension'' field');
                end
            end
            
            % set boundary values
            if all(isfield(argin, {'ub','lb'}))
                obj =  setBoundary(obj, argin.lb, argin.ub);
            elseif isfield(argin, 'lb')
                obj =  setBoundary(obj, argin.lb, inf);
            elseif isfield(argin, 'ub')
                obj =  setBoundary(obj, -inf, argin.ub);
            else
                obj =  setBoundary(obj, -inf, inf);
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
        obj = setIndices(obj, index);
        
        obj = setBoundary(obj, lowerbound, upperbound);
        
        obj = setInitialValue(obj, x);
        
        obj = updateProp(obj, varargin);
    end
end