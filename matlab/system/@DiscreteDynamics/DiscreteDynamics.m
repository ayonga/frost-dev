classdef DiscreteDynamics
    % DiscreteDynamics defines properties and functions related to a
    % discrete transition of the hybrid dynamical system
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
        
       
        
        % the direction of the guard
        %
        % Possible value of guard_direction:
        %   - +1: if guard function cross zero from negative to positive
        %   - -1: if guard function cross zero from positive to negative
        %
        % @type integer @default -1        
        guard_direction = -1;
        
        
        % the threshold profile of the guard condition, normally zero
        %
        % @type double @default 0
        guard_profile = 0;
        
        % the type of guard condition
        %
        % @type char
        guard_type  
        
        % the function handle to the function that computes the guard value
        %
        % @type function_handle
        guard_func
        
        % the function handle to the function that computes the jacobian of guard
        %
        % @type function_handle
        guard_jac
        
        % the reset map options
        %
        % Required fields for resetmap_options:
        %  hasImpact: indicates there is a rigid impact @type logical
        %  isSwapping: indicates whether swap the stant/non-stance legs
        %  @type logical @default false
        %
        % @type struct
        options
        
        
        
        
        
    end
    
    %% Public methods
    methods
        
        function obj = DiscreteDynamics(name)
            % the default calss constructor
            %
            % Parameters:
            % name: the name of the discrete map @type char
            %
            % Return values:
            % obj: the class object
            
            % call the superclass constructor
            obj.name = name;
            
            % initialize the default options
            obj.options = struct(...
                'apply_rigid_impact',false,...
                'relabel_coordinates',false);
        end
        
        function obj = setOptions(obj, dmap_options)
            % setup the reset map options
            %
            % Parameters:
            %  dmap_options: the option for the reset map @type struct
            
            
            obj.options = struct_overlay(obj.options,dmap_options);
        end
        
        function obj = setGuard(obj, guard)
            % setup the discrete transition guard configurations
            %
            % Parameters:
            %  guard: guard configurations @type struct
            
            
            obj.guard_direction = guard.direction;
            obj.guard_profile = guard.value;
            obj.guard_type = guard.type;
            
            if strcmp(obj.guard_type,'kinematics')
                % then there should be associated mex file exists
                
                % check existance of mex files
                %         assert(exist(strcat('guard_',obj.name),'file')==3,...
                %             'The MEX file could not be found: %s\n',...
                %             strcat('guard_',obj.name)); % 3 - Mex-file
                %         assert(exist(strcat('Jguard_',obj.name),'file')==3,...
                %             'The MEX file could not be found: %s\n',...
                %             strcat('Jguard_',obj.name)); % 3 - Mex-file
                
                obj.guard_func = str2func(strcat('guard_',guard.name));
                obj.guard_jac = str2func(strcat('Jguard_',guard.name));
            end
        end
            
        
        function obj = set.guard_profile(obj, value)
            % set a new threshold profile for the guard condition
            %
            % @note the guard profile could be either a number or a mesh
            %
            % Parameters:
            %  value: the new guard profile value
            
            % argument check
            narginchk(2,2);
            
            
            fprintf('updating the guard threshold.\n');
            obj.guard_profile = value;
            
            
            
        end
        
        
        function obj = set.guard_direction(obj, newDir)
            % set the direction of the guard evaluation
            %
            % Parameters:
            %  newDir: the new guard direction @type integer
            
            % argument check
            narginchk(2,2);
            
            obj.guard_direction = newDir;
            fprintf('New guard direction: %d\n', newDir);
            
            
            
            
        end
        
        function obj = set.guard_type(obj, type)
            % set the type of the guard condition
            %
            % Parameters:
            %  newDir: the new guard direction @type integer
            
            % argument check
            narginchk(2,2);
            
            obj.guard_type = type;
            fprintf('New guard direction: %s\n', type);
            
        end
            
           
        
    end
        
    
end

