classdef KinematicOrientation < Kinematics
    % Defines three dimensional orientations of a body frame rigidly
    % attached to a link, i.e., it belongs to SO(3).
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
        % The parent link name of the body frame
        %
        % @type char
        ParentLink
        
        % The (x,y,z)-axis of the rotation
        %
        % @type char
        Axis
        
        
        
        
    end % properties
    
    
    
    
    
    methods
        
        function obj = KinematicOrientation(varargin)
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
            
            if isfield(objStruct, 'ParentLink')
                obj.ParentLink = objStruct.ParentLink;
            end
            
            
            
            
        end
        
        
        
        
    end % methods
    
    properties (Dependent, Hidden)
        % The index of the axis
        %
        % @type integer
        pIndex
    end
    
    %% set/get methods
    methods
        function pIndex = get.pIndex(obj)
            
            if ~isempty(obj.Axis)
                error('The ''Axis'' of the orientation NOT assigned.');
            end
            pIndex = 3 + find(strcmpi(obj.Axis, {'x','y','z'}));
        end
        
        function obj = set.ParentLink(obj, parent)
            
            assert(ischar(parent),'The ''ParentLink'' should be a valid string.');
            obj.ParentLink = parent;
        end
        
        function obj = set.Axis(obj, axis)
            
            
            % set direction axis
            valid_axes = {'x','y','z'};
            obj.Axis = validatestring(axis,valid_axes);
        end
        
    end
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj, model)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            valid_links = {model.links.name};
            % validate parent link name (case insensitive)
            parent  = validatestring(obj.ParentLink,valid_links);
            
            if isempty(obj.Offset)
                error('The ''Offset'' of the position NOT assigned.');
            end
            
            % create a cell as the input argument, use zero offsets
            arg = {parent,[0,0,0]};
            % class specific command for computing orientation based kinematic constraint
            cmd = ['ComputeSpatialPositions[',cell2tensor(arg),'][[1,{',num2str(obj.pIndex),'}]]'];
        end
        
        % overload the Jacobian compilation command
        function cmd = getJacMathCommand(obj, model)
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint's Jacobian.
            
            valid_links = {model.links.name};
            % validate parent link name (case insensitive)
            parent  = validatestring(obj.ParentLink,valid_links);
            
            if isempty(obj.Offset)
                error('The ''Offset'' of the position NOT assigned.');
            end
            
            % create a cell as the input argument, use zero offsets
            arg = {parent,[0,0,0]};
            % class specific command for computing rotational spatial Jacobian of an orientation
            cmd = ['ComputeSpatialJacobians[',cell2tensor(arg),'][[1,{',num2str(obj.pIndex),'}]]'];
        end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
