classdef ParamVariable < BoundedVariable
    % ParamVariable: a class to describe dynamical system inputs.
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
        % The value of the parameter variable
        %
        % @type numerical
        Value
        
    end
    
    methods
        function obj = ParamVariable(name, dim, lb, ub, val)
           % ParamVariable construct a class object
           %
           % Example:
           % % parameters, default boundary values (-inf,inf)
           % p1 = ParamVariable('p',[1,6]) 
           %
           % % uniform boundary values (-1,2), constraint wrench
           % p2 = ParamVariable('p2',[6,5],-1,2) 
           %
           % % non-uniform boudar values (lb,ub), external force
           % lb = [-1.1,-0.1,-4.2,0,0.5]';
           % ub = [1.1,2.1,4.2,2,3.5]';
           % p3 = ParamVariable('p3',[5,1],lb,ub) 
           % 
           
           
           arguments
               name char = ''
               dim {mustBeInteger,mustBePositive} = []
               lb double = []
               ub double = []
               val double = []
           end
           
           obj = obj@BoundedVariable(name, dim, lb, ub);
           
           if ~isempty(val)
               obj.Value = val;
           end
        end
        
        
        function setValue(obj, val)
            
            arguments
                obj ParamVariable
                val double = []
            end
            
            dim = dimension(obj);
            
            if isempty(val)
                val = zeros(dim);
            end
            if isscalar(val)
                val = val*ones(dim);
            end
            if size(val,1) ~= dim(1) || size(val,2) ~= dim(2)
                eid = 'Size:wrongDimensions';
                msg = ['Value must have dimensions: ',num2str(dim(1)),' x ', num2str(dim(2))];
                throwAsCaller(MException(eid,msg))
            end
            obj.Value = val;
            
        end
    end
    
end

