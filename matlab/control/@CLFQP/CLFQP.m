classdef CLFQP < Controller
    % This class defines a class of Control Lyapunov Functions (CLFs) that
    % use quadratic programming (QP)
    %
    % @todo implement the CLF-QP controller
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
        
        function obj = CLFQP(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name); %#ok<NASGU>
            error('This class has not been completely defined yet.');
            
        end
        
        
        
    end
    
    methods
        [u, extra] = calcControl(obj, t, qe, dqe, vfc, gfc, domain);
    end
    
end