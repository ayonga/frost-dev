classdef BoundedVariable < SymVariable
    % BoundedVariable: a class represents variables with lower and upper
    % boundaries
    %
    % @author ayonga @date 2021-12-18
    %
    % Copyright (c) 2021, Cyberbotics Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=protected, GetAccess=public)
        
        % The name of the variable
        %
        % @type char
        Name char
        
        % The lower limit of the state variables
        %
        % @default -Inf
        %
        % @type colvec
        LowerBound (:,:) double 
        
        % The upper limit of the state variables        
        %
        % @default Inf
        %
        % @type colvec
        UpperBound (:,:) double 
        
        % A descriptive alias of the variable (e.g., 'Position' for 'q')
        %
        % @type char
        Alias char
        
        
    end
    
    
    
    methods
        function obj = BoundedVariable(name, dim, lb, ub)
           % BoundedVariable construct a class object
           %
           % Example:
           % x = BoundedVariable('x',5) % default boundary values (-inf,inf)
           
           
          
           
           arguments
               name char = ''
               dim {mustBeInteger,mustBePositive} = []
               lb  double = []
               ub  double = []
           end
           
           obj = obj@SymVariable(name,dim);
           obj.Name = name;
           
           
           dim = dimension(obj);
           
           if ~isempty(dim) 
               obj.LowerBound = -inf(dim);
               obj.UpperBound = inf(dim);
               updateBound(obj,lb,ub);
           end
           
           
        end
    end
    
    methods
        function setAlias(obj, alias)
            
            if ischar(alias)
                obj.Alias = alias;
            else
                error('The `Alias` argument must be a `char` or `string` object.');
            end
        end
        
        
        
        function obj = updateBound(obj, lb, ub)
            % updateBound(obj,lb,ub) updates the lower/upper boundary
            % values of the state variable
            %
            % Example:
            % x = updateBound(x,-1,2) % uniform boundary values (-1,2)
            %
            % x = updateBound(x,-1) % only lower bound, ub default
            %
            % x = updateBound(x,[],1) % only upper bound, lb default
            %
            % lb = [-1.1,-0.1,-4.2,0,0.5]';
            % ub = [1.1,2.1,4.2,2,3.5]';
            % x = updateBound(x,lb,ub) % non-uniform boudar values
            % (lb,ub)
            
            
            arguments
                obj 
                lb (:,:) double {mustBeReal} = []
                ub (:,:) double {mustBeReal} = []
            end
            
            dim = obj.Dimension;
            assert(~isempty(dim),'The variable object is an empty object. Initialize a non-empty object first.');
            
            if ~isempty(lb)
                if isscalar(lb)
                    lb = lb*ones(dim);
                end
                if any(size(lb) ~= dim)
                    eid = 'Size:wrongDimensions';
                    msg = ['lb must have dimensions: ',num2str(dim(1)),' x ', num2str(dim(2))];
                    throwAsCaller(MException(eid,msg))
                end
                obj.LowerBound = lb;
            end
            
            
            if ~isempty(ub)
                if isscalar(ub)
                    ub = ub*ones(dim);
                end
                if any(size(ub) ~= dim)
                    eid = 'Size:wrongDimensions';
                    msg = ['ub must have dimensions: ',num2str(dim(1)),' x ', num2str(dim(2))];
                    throwAsCaller(MException(eid,msg))
                end
                obj.UpperBound = ub;
            end
            
            if ~isempty(obj.UpperBound) && ~isempty(obj.LowerBound)
                assert(any(any(obj.UpperBound >= obj.LowerBound)),...
                    'The lowerbound is greater than the upper bound. Variable name: %s\n', obj.Name);
            end
        end
        
    end
    
%     methods (Access='protected')
%         function propgrp = getPropertyGroups(obj)
%             proplist = struct('Name',obj.Name,...
%                 'LowerBound',obj.LowerBound,...
%                 'UpperBound',obj.UpperBound);
%             if ~isempty(obj.Alias)
%                 proplist.Alias = obj.Alias;
%             end
%             if ~isempty(obj.label)
%                 proplist.Labels = obj.label;
%             end
%             propgrp = matlab.mixin.util.PropertyGroup(proplist);
%         end
%     end
    
end

