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
        
        % The option of the reset map associated with the switching surface
        %
        % @type struct
        DeltaOpts
        
        
        
    end % properties
    
    methods
        
        function obj = Guard(name, varargin)
            % the class constructor function
            
            assert(ischar(name), 'The Name of the object must be a string.');
            obj.Name = name;
            
            argin = struct(varargin{:});
            
            if isfield(argin, 'Condition')
                obj.Condition = argin.Condition;
            else
                obj.Condition = [];
            end
                
            if isfield(argin, 'Direction')
                obj.Direction = argin.Direction;
            else
                obj.Direction = 1;
            end
            
            if isfield(argin, 'DeltaOpts')
                obj.DeltaOpts = argin.DeltaOpts;
            else
                obj.DeltaOpts = struct;
            end
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
        
        function obj = set.Condition(obj, cond)
            
            if ~isempty(cond)
                assert(ischar(cond), 'The guard condition must be a string.');
            end
            obj.Condition = cond;
        end
        
        function obj = set.Direction(obj, direction)
           
            assert(direction==1 || direction ==0 || direction == -1, ...
                'The direction must be one of (1,0,-1).');
            obj.Direction = direction;
        end
        
        function obj = set.DeltaOpts(obj, delta)
           
            assert(isstruct(delta),...
                'The reset map options must be a struct.');
            obj.DeltaOpts = struct('ApplyImpact', false,...
                'CoordinateRelabelMatrix', []);
            if isfield(delta, 'ApplyImpact')
                obj.DeltaOpts.ApplyImpact = delta.ApplyImpact;
            end
            if isfield(delta, 'CoordinateRelabelMatrix')
                obj.DeltaOpts.CoordinateRelabelMatrix = delta.CoordinateRelabelMatrix;
            end
            
        end
        
    end % methods
    
    
    
end % classdef