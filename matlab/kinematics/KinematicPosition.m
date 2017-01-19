classdef KinematicPosition < Kinematics
    % Defines one of the three dimensional Cartesian positions of a fixed
    % point on a rigid link
    % 
    %
    % @author ayonga @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties 
        % The name of the rigid link on which the point is attached to
        %
        % @type char
        ParentLink
        
        % The 3-dimensional offset of the point in the body joint
        % coordinates that is rigidly attached to parent link
        %
        % @type rowvec
        Offset
        
        % The (x,y,z)-axis index of the position. This axis should be the
        % axis in the world (inertial) frame, not the body coordinates.
        %
        % @type char
        Axis
        
    end % properties
    
    
    
    methods
        
        function obj = KinematicPosition(varargin)
            % The constructor function
            %
            % @copydetails Kinematics::Kinematics()
            %
            % See also: Kinematics
            
            
            obj = obj@Kinematics(varargin{:});
            if nargin == 0
                return;
            end
            
            objStruct = struct(varargin{:});
            
            if isfield(objStruct, 'Axis')                
                obj.Axis = objStruct.Axis;
            end
            
            if isfield(objStruct, 'ParentLink')
                obj.ParentLink = objStruct.ParentLink;
            end
            
            if isfield(objStruct, 'Offset')
                obj.Offset = objStruct.Offset;
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
            
            
            if isempty(obj.Axis)
                error('The ''Axis'' of the orientation NOT assigned.');
            end
            pIndex = find(strcmpi(obj.Axis, {'x','y','z'}));
        end
        
         function obj = set.Offset(obj, offset)
            
            % covnert to row vector first
            if iscolumn(offset)
                offset = offset';
            end
            % validate if it is a numeric 1x3 vector
            validateattributes(offset, {'numeric'},{'size',[1,3]});
            
            obj.Offset = offset;
            
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
            
            valid_links = {model.Links.name};
            % validate parent link name (case insensitive)
            parent  = validatestring(obj.ParentLink,valid_links);
            
            
            if isempty(obj.Offset)
                error('The ''Offset'' of the position NOT assigned.');
            end
            
            % create a cell as the input argument
            arg = {parent,obj.Offset};
            % command for rigid position
            cmd = ['ComputeSpatialPositions[',cell2tensor(arg),'][[1,{',num2str(obj.pIndex),'}]]'];
        end
        
        % overload the Jacobian compilation command
        % function cmd = getJacMathCommand(obj, model)
        %     % This function returns the Mathematica command to compile the
        %     % symbolic expression for the kinematic constraint's Jacobian.
        %
        %     valid_links = {model.Links.name};
        %     % validate parent link name (case insensitive)
        %     parent  = validatestring(obj.ParentLink,valid_links);
        %
        %
        %     if isempty(obj.Offset)
        %         error('The ''Offset'' of the position NOT assigned.');
        %     end
        %
        %     % create a cell as the input argument
        %     arg = {parent,obj.Offset};
        %     % class specific command for computing rotational spatial
        %     % Jacobian of an position
        %     cmd = ['ComputeSpatialJacobians[',cell2tensor(arg),'][[1,{',num2str(obj.pIndex),'}]]'];
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
