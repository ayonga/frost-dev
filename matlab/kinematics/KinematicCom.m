classdef KinematicCom < Kinematics
    % Defines the center of positions of a rigid body model
    % 
    %
    % @author Ayonga Hereid @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=protected, GetAccess=public)
        % The (x,y,z)-axis index of the position
        %
        % @type integer
        Axis
    end % properties
    
    
    methods
        
        function obj = KinematicCom(name, axis, varargin)
            % The constructor function
            %
            % Parameters:
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char        
            %  axis: one of the (x,y,z) axis @type char
            %  linear: indicates whether linearize the original
            %  expressoin @type logical
            %  varargin: superclass options @type varargin
            
            
            obj = obj@Kinematics(name, varargin{:});
            
            % the dimension is always 1
            obj.Dimension = 1;
            
            
            if nargin > 1
                % set direction axis
                valid_axis = {'x','y','z'};
                axis = validatestring(axis,valid_axis);
                obj.Axis = find(strcmpi(axis, valid_axis));
            end
        end
        
        
        
    end % methods
    
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            cmd = ['ComputeComPosition[][[1,{',num2str(obj.Axis),'}]]'];
        end
        
        % use default function
        % function cmd = getJacMathCommand(obj)
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
