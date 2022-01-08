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
    
    
    properties (SetAccess=protected)
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
        Dimension 
        
        
        % The lower limit of the optimization variable
        %
        % @type colvec
        LowerBound
        
        % The upper limit of the optimization variable
        %
        % @type colvec
        UpperBound
        
        
        
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
        
        % The index of the current variable in an array of NlpVariable
        % objects
        %
        % @type colvec
        Indices
        
    end
    
    
    methods
        
        function obj = NlpVariable(var, props)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %   Name: name of the variable @type char
            %   Dimension: dimension of the variable @type integer
            %   lb: lower limit @type colvec
            %   ub: upper limit @type colvec
            %   x0: a typical value of the variable @type colvec
            
            arguments
                var BoundedVariable = BoundedVariable.empty()
                props.Name char {mustBeValidVariableName}
                props.Dimension double {mustBeInteger,mustBeNonnegative,mustBeScalarOrEmpty} 
                props.lb (:,1) double {mustBeReal,mustBeNonNan} = []
                props.ub (:,1) double {mustBeReal,mustBeNonNan} = []
                props.x0 (:,1) double {mustBeReal,mustBeNonNan} = []
            end
            
            % if no input argument, create an empty object
            %             if nargin == 0
            %                 return;
            %             end
            
            if ~isempty(var)
                obj.Name = var.Name;
                obj.Dimension = prod(var.Dimension);
                obj.LowerBound = var.LowerBound(:);
                obj.UpperBound = var.UpperBound(:);
            else
                if isfield(props,'Name')
                    obj.Name = props.Name;
                end
                
                if isfield(props, 'Dimension')
                    obj.Dimension = props.Dimension;
                end
            end
                
            
                        
            updateProp(obj, 'lb', props.lb, 'ub', props.ub, 'x0', props.x0);
            
            
        end
        
        
        
        
        
    end
    
   
    
    %% methods defined in external files
    methods
        obj = setIndices(obj, index);                
        
        obj = updateProp(obj, prop);
    end
    
    
end