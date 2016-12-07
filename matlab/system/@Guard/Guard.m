classdef Guard
    % Guard defines properties and functions related to a guard condition
    % of the hybrid system model.
    % 
    %
    % @author ayonga @date 2016-11-10
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    %% Public properties
    properties (Access = public)
    end
    
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        name
        
        % the guard options
        %
        % @type struct
        options
       
        
        % the guard condition
        
        % the direction of the guard
        %
        % Possible values of direction:
        %   - +1: if guard function cross zero from negative to positive
        %   - -1: if guard function cross zero from positive to negative
        %
        % @type real @default -1        
        direction
        
        
        % the threshold profile of the guard condition, normally zero
        %
        % @type double @default 0
        threshold
        
        % the type of guard condition
        %
        % @type char
        type  
        
        % a structure of function names defined for the guard. Each field
        % of 'funcs' specifies the name of a function that used for a
        % certain computation of the guard.
        %
        % Optional fields of funcs:
        %
        % @type struct
        funcs
        
        % a Kinematic object associatied with the guard condition
        %
        % This field is only affective when the type is either 'kinematic'
        % or 'force'
        %
        % @type Kinematics
        kin
        
        
        
        
    end %properties
    
    
    methods
        
        function obj = Guard(name, varargin)
            % the constructor function for Guard class
            %
            % Parameters:
            % name: the name of the guard @type char
            % varargin: the class options 
            % direction: the direction of the guard condition 
            % type: the type of the guard condition
            %
            
            if nargin > 0
                if ischar(name)
                    obj.name = name;
                else
                    warning('The domain name must be a string.');
                end
            end
            
            % parse variable input arguments
            default_direction = -1;
            expected_direction = [1, -1];
            
            default_type = 'kinematic';
            expected_types = {'kinematic','force','time'};
            
            p = inputParser;
            p.addParameter('direction', default_direction, @(x) any(x==expected_direction));
            p.addParameter('type', default_type, ...
                @(x) any(validatestring(x, expected_types)));
            
            parse(p,varargin{:});
            
            obj.direction = p.Results.direction;
            obj.type      = p.Results.type;
            
            
            % default options
            obj.options = struct();
        end %Guard
        
        
        
        
        
        
        
        
    end %methods
    
    %% methods defined in separate files
    methods
        obj = exportFunction(obj, export_path, do_build);
        
        obj = compileFunction(obj, model, varargin);
        
        obj = setKinematicCondition(obj, kin);
    end
    
end %classdef
