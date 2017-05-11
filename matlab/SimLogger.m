classdef SimLogger < handle & matlab.mixin.Copyable
    % A class for logging the internal data over time during a ODE
    % simulation process. 
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
    
    
    methods
        
    end
    
    properties
        % recorded data at one time instant
        %
        % @type struct
        calc
                
        
        % The static data that are time-independent
        %
        % @type struct
        static

        
    end
    
    properties (Dependent)
        % The time-dependent data along the simulated trajectory
        %
        % @type struct
        flow
    end

    properties (SetAccess = protected)
        
        
        %

        % The dynamical system model associated with the logger
        %
        % @type DynamicalSystem
        plant
    end

    properties (Access=protected)
        % a stack of recorded data during a certain time duration
        %
        % @type cell
        calcs
    end
    
    properties (Access=private)
        flow_
    end
    
    methods
        
        function obj = SimLogger(plant)
            % Constructor function
            %
            % Parameters:
            % plant: the dynamical system model @type DynamicalSystem
            
            % check the type of the plant
            validateattributes(plant,{'DynamicalSystem'},...
                {},'SimLogger','plant');
            obj.plant = plant;
            
            obj.initialize();
            
        end
        
        
        function obj = initialize(obj)
            % Initializes the logger 
            
            
            [obj.calc] = deal(struct);
            [obj.calcs] = deal({});
            [obj.static] = deal(struct);
        end
        
        function status = updateLog(obj)
            % push the current recorded data into the stack
            
            
            % push recorded data
            obj.calcs{end+1} = obj.calc;
            
            % clear the record
            obj.calc = struct;
            
            % return status
            status = 0;
            
        end
        
        function status = updateLastLog(obj)
            % updates the last set of recorded data
            
            % remove the last recorded dateset
            obj.calcs{end} = obj.calc;
            
            % Concatenate the cell array into a struct
            obj.flow_ = horzcat_fields(cell2mat(obj.calcs));

            % return status
            status = 0;
        end
            
        function flow = get.flow(obj)
            
            if isempty(obj.flow_)
                % if the flow data has not been concatenated, then
                % concatenate first
                obj.flow_ = horzcat_fields(cell2mat(obj.calcs));
            end
            flow = obj.flow_;
        end
    end
    
    
end