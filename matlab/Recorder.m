classdef Recorder < handle
    % This is a simple recorder class that record the data from ODE
    % simulation
    %
    %
    % @author Ayonga Hereid @date 2016-09-26
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties
        % recorded data at one time instant
        %
        % @type struct
        calc
        
        % a stack of recorded data during a certain time duration
        %
        % @type cell
        calcStack
        
    end
    
    methods
        
        function obj = Recorder()
            % Constructor function
            %
            obj.calc = [];
            
            obj.calcStack = {};
            
        end
        
        
        function status = pushRecord(obj)
            % push the current recorded data into the stack
            %
            
            % push recorded data
            obj.calcStack{end+1} = obj.calc;
            
            % clear the record
            obj.calc = [];
            
            % return status
            status = 0;
            
        end
        
        function status = updateLastRecord(obj)
            % updated the last record in the stack with computed data at
            % the actual guard
            % 
            %
            
            % push recorded data
            obj.calcStack{end} = obj.calc;
            
            % clear the record
            obj.calc = [];
            
            % return status
            status = 0;
            
        end
            
        
    end
    
end