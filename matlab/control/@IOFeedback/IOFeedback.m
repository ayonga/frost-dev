classdef IOFeedback < Controller
    % This class defines the classic input-output feedback linearization
    % controller
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
        
        function obj = IOFeedback(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name);
             
            
        end
        
        
        
    end
    
    methods
        obj = setParam(obj, varargin);
        
        [u, extra] = calcControl(obj, t, x, vfc, gfc, domain, params);
    end
    
end