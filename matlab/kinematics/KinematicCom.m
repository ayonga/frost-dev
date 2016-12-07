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
    
    properties 
        % The (x,y,z)-axis index of the position
        %
        % @type integer
        Axis
    end % properties
    
    
    methods
        
        function obj = KinematicCom(varargin)
            % The constructor function
            %
            % @copydetails Kinematics::Kinematics()
            
            
            obj = obj@Kinematics(varargin{:});
            if nargin == 0
                return;
            end
            % the dimension is always 1
            obj.Dimension = 1;
            objStruct = struct(varargin{:});
            
            if isfield(objStruct, 'Axis')                
                obj.Axis = objStruct.Axis;
            end
        end
        
        function obj = set.Axis(obj, axis)
            
            % set direction axis
            valid_axes = {'x','y','z'};
            obj.Axis = validatestring(axis,valid_axes);
        end
        
    end % methods
    
    properties (Dependent, Hidden)
        % The index of the axis
        %
        % @type integer
        pIndex
    end
    
    methods
        function pIndex = get.pIndex(obj)
            
            if ~isempty(obj.Axis)
                error('The ''Axis'' of the orientation NOT assigned.');
            end
            pIndex = 3 + find(strcmpi(obj.Axis, {'x','y','z'}));
        end
    end
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj, model)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            cmd = ['ComputeComPosition[][[1,{',num2str(obj.pIndex),'}]]'];
        end
        
        % use default function
        % function cmd = getJacMathCommand(obj)
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
