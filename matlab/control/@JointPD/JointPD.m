classdef JointPD < Controller
    % This class defines a PD feedback control on the joint space
    %
    % @author ayonga @date 2016-10-14
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        
        
        
    end
    
    methods
        
        function obj = JointPD(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name);
             
            % initialize default control parameters
            ep = 10;
            obj.Param.kp = ep^2;
            obj.Param.kd = 2*ep;
        end
        
        
        
    end
    
    methods
        obj = setParam(obj, varargin);
        
        [u, extra] = calcControl(obj, qa, dqa, qd, dqd, Be)
    end
    
end