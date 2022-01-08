classdef StateVariable < BoundedVariable
    % StateVariable: a class to describe dynamical system state variables.
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
        
    end
    
    methods
        function obj = StateVariable(name, dim, lb, ub)
           % StateVariable construct a class object
           
           arguments
               name char = ''
               dim double {mustBeInteger,mustBePositive,mustBeScalarOrEmpty} = []
               lb double = []
               ub double = []
           end
           
           obj = obj@BoundedVariable(name, dim, lb, ub);
           
           
        end
        
       
    end
    
    
    
end

