classdef Guard
    % Guard defines a switching surface or a guard of a hybrid system
    % model. 
    %
    % @author ayonga @date 2016-09-29
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char 
        Name
        
        % The guard condition of the switching surface.
        %
        % The guard condition must be a member of unilateral constraints of
        % the source domain.
        %
        % @type char        
        Condition
        
        % The direction of the switching surface
        %
        % @type integer
        Direction
        
        %% Reset map
        % A reset map of system states associated with the guard 
        %
        % The reset map will be applied to the target continuous domain
        % prior to the beginning of the domain
        %
        % Required fields of ResetMap:
        %  RigidImpact: indicates whether it goes through a rigid impact
        %  @type logical
        %  RelabelMatrix: the coordinate relabel matrix @type matrix
        %  ResetPoint: a point to be reset to the origin (0,0,0) @type KinematicContact 
        %
        % @type struct
        ResetMap
        
        
        
    end % properties
    
    methods
        
        function obj = Guard(name, varargin)
            % the class constructor function
            
            assert(ischar(name), 'The Name of the object must be a string.');
            obj.Name = name;
            
            argin = struct(varargin{:});
            
            if isfield(argin, 'Condition')
                obj = setCondition(obj, argin.Condition);
            else
                obj.Condition = [];
            end
                
            if isfield(argin, 'Direction')
                obj = setDirection(obj, argin.Direction);
            else
                obj.Direction = -1;
            end
            
            obj.ResetMap = struct(...
                'RigidImpact', false,...
                'RelabelMatrix', [],...
                'ResetPoint',[]);
        end
        
        
        function thres = calcThreshold(obj, t, qe, dqe)
            % Calculates the threshold value of the guard condition
            %
            % To use particular threshold value, such as ground heights,
            % make sure to overwrite this function in the subclass.
            %
            % Parameters: 
            % t: the time instant @type double
            % qe: the joint configuration @type colvec
            % dqe: the joint velocities @type colvec
            
            thres = 0;
    
        end
        
        function obj = setCondition(obj, cond)
            
            if ~isempty(cond)
                assert(ischar(cond), 'The guard condition must be a string.');
            end
            obj.Condition = cond;
        end
        
        function obj = setDirection(obj, direction)
           
            assert(direction==1 || direction ==0 || direction == -1, ...
                'The direction must be one of (1,0,-1).');
            obj.Direction = direction;
        end
        
        
        
    end % methods
    
    methods
       
        
        obj = setResetMap(obj, model, rigid_impact, relabel_matrix, reset_point);
        
        [x_post] = calcResetMap(obj, model, x_pre, target);
    end
    
end % classdef