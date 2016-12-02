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
        name
        
        % The dimension the optimization variable
        %
        % When we define a optimization variable, we assume that it
        % represnts a vector of variable that belongs to a particular
        % group. For example, the joint configurations 'q' and control
        % inputs 'u'. The 'dimension' specifies the length of this vector.
        %
        % @type integer
        dimension
        
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
        x0
        
        % The lower limit of the optimization variable
        %
        % @type colvec
        lb
        
        % The upper limit of the optimization variable
        %
        % @type colvec
        ub
        
        % The index of the current variable in an array of NlpVariable
        % objects
        %
        % @type colvec
        indices
    end
    
    
    methods
        function obj = NlpVariable(varargin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable input arguments, in detail:
            %   name: name of the variable @type char
            %   dimension: dimension of the variable @type integer
            %   lb: lower limit @type colvec
            %   ub: upper limit @type colvec
            %   x0: a typical value of the variable @type colvec
            
            
            % if no input argument, create an empty object
            if nargin == 0
                return;
            end
            
            
            
            obj.name = varargin{1};
            
            % set the dimension to be 1 by default
            if nargin > 1
                obj.dimension = varargin{2};
            else
                obj.dimension = 1;
            end
            
            % set the lower limit to '-inf' by default
            if nargin > 2
                lowerbound = varargin{3};
            else
                lowerbound = -Inf;
                warning('NlpVariable:checkArgs',...
                    'Lower limit not specified, automatically set to -Inf.');
            end
            
            % set the upper limit to 'inf' by default
            if nargin > 3
                upperbound = varargin{4};
            else
                upperbound = Inf;
                warning('NlpVariable:checkArgs',...
                    'Upper limit not specified, automatically set to Inf.');
            end
            
           
            
            % expand the lower/upper limits if they are given as scalar values
            if isscalar(lowerbound)
                lowerbound = lowerbound*ones(obj.dimension,1);
            end
            if isscalar(upperbound)
                upperbound = upperbound*ones(obj.dimension,1);
            end
            
            assert(size(lowerbound,1) == 1 || size(lowerbound,2) == 1,...
                'NlpVariable:wrongDimension',...
                'The lower limit should be a vector or a scalar');
            
            assert(size(upperbound,1) == 1 || size(upperbound,2) == 1,...
                'NlpVariable:wrongDimension',...
                'The upper limit should be a vector or a scalar');
            
            % specifies lower/upper limits
            if size(lowerbound,1) == 1
                obj.lb = transpose(lowerbound); % make column vector
            else
                obj.lb = lowerbound;
            end
            if size(upperbound,1) == 1
                obj.ub = transpose(upperbound); % make column vector
            else
                obj.ub = upperbound;
            end
            
            % determine the typical value
            if nargin > 4
                x = varargin{5};
                if isscalar(x)
                    x = x*ones(obj.dimension,1);
                else
                    if size(x,1) == 1
                        x = transpose(x);
                    end
                end
                obj.x0 = x;
            else
                % preallocate
                
                lb_tmp = obj.lb;
                ub_tmp = obj.ub;
                
                % replace infinity with very high numbers
                lb_tmp(lb_tmp==-inf) = -1e5;
                ub_tmp(ub_tmp==inf)  = 1e5;
                
                obj.x0 = (ub_tmp - lb_tmp)/2;
                              
            end
        end
        
        
        function obj = genIndices(obj, index_offset)
            % Generates indinces of each variable if the input is an array
            % of NlpVariable objects.
            %
            % Parameters:
            %  obj: an array of NlpVariable objects @type NlpVariable
            %  index_offset: the offset of the starting index of the variable
            %  array indices @type integer
            
            % get the size of object array
            num_obj = numel(obj);
            
            % If an offset is not specified, set it to zero.
            if nargin < 2
                index_offset = 0;
            end
            
            for i = 1:num_obj
                % set the index
                obj(i).indices = index_offset + cumsum(ones(obj(i).dimension, 1));
                            
                % increments (updates) offset
                index_offset = index_offset + obj(i).dimension;
            end
        end
        
        function obj = appendTo(obj, vars)
            % Appends the new NlpVariable 'vars' to the existing
            % NlpVariable array
            %
            % Parameters:
            %  obj: an array of NlpVariable objects @type NlpVariable
            %  vars: a new NlpVariables to be appended to @type NlpVariable
            
            assert(isa(vars,'NlpVariable'),...
                'NlpVariable:incorrectDataType',...
                'The variables that append to the array must be a NlpVariable object.\n');
            
            last_entry = numel(obj);
            
            nVars = numel(vars);
            
            obj(last_entry+1:last_entry+nVars) = vars;
            
        end
    end
end