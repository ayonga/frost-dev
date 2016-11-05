classdef NlpVar
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
    
    properties 
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
        
        % The lower limit of the optimization variable
        %
        % @type colvec
        lb
        
        % The upper limit of the optimization variable
        %
        % @type colvec
        ub
        
    end
    
    
    methods
        function obj = NlpVar(name, dimension, lb, ub)
            % The class constructor function
            %
            % Parameters:
            % name: the variable name string
            % dimension: the dimension of the variable vector
            % lb: the lower limits, uniform bound can be provided as a scalar
            % ub: the upper limits, uniform bound can be provided as a scalar
            
            obj.name = name;
            obj.dimension = dimension;
            
            
            % set the lower limit to '-inf' by default
            if nargin < 3
                lb = -Inf;
                warning('NlpVar:checkArgs',...
                    'Lower limit not specified, automatically set to -Inf.');
            end
            
            % set the upper limit to 'inf' by default
            if nargin < 4
                ub = Inf;
                warning('NlpVar:checkArgs',...
                    'Upper limit not specified, automatically set to Inf.');
            end
            
            
            % expand the lower/upper limits if they are given as scalar values
            if isscalar(lb)
                lb = lb*ones(dimension,1);
            end
            if isscalar(ub)
                ub = ub*ones(dimension,1);
            end
            
            assert(size(lb,1) == 1 || size(lb,2) == 1,...
                'NlpVar:wrongDimension',...
                'The lower limit should be a vector or a scalar');
            
            assert(size(ub,1) == 1 || size(ub,2) == 1,...
                'NlpVar:wrongDimension',...
                'The upper limit should be a vector or a scalar');
            
            % specifies lower/upper limits
            if size(lb,1) == 1
                obj.lb = transpose(lb); % make column vector
            else
                obj.lb = lb;
            end
            if size(ub,1) == 1
                obj.ub = transpose(ub); % make column vector
            else
                obj.ub = ub;
            end
        end
    end
end