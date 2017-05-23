classdef Controller < handle
    % This abstract class defines interfaces to configuration and
    % functionalities of different types of controllers
    %
    % @author ayonga @date 2016-10-04
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        % The name of the controller
        %
        % @type char
        Name
        
        % The parameters of the controller
        %
        % @type struct
        Param
        
        
    end
    
    methods
        
        function obj = Controller(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            assert(ischar(name), 'The controller name must be a char variable');
            
            obj.Name = name;
            obj.Param = struct;
             
        end
        
        
        function obj = setParamValue(obj, varargin)
            % set the actual value of the controller parameters
            %
            % Parameters:
            % varargin: the parameter values @type struct
            
            % convert to struct
            params = struct(varargin{:});
            
            update_fields = intersect(fieldnames(obj.params_),fieldnames(params));
            nfields = numel(update_fields);
            if nfields > 0
                for i=1:nfields
                    field = update_fields{i};
                    obj.params_.(field) = params.(field);
                end
            end
            
        end
    end
    
    methods (Abstract)
        % calculate the control input
        u = calcControl(obj, t, x, vfc, gfc, plant, params, logger);
    end
    
end