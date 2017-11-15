classdef RigidJoint < CoordinateFrame
    % A coordinate frame that is rigidly attached to the origin a rigid
    % joint and the child link of the joint. In addition, this class stores
    % the type, rotation axis, child link, and limit of the rigid joints.
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (SetAccess=protected, GetAccess=public)
        % The type of the rigid joint
        %
        % @note valid joint types include: 
        % revolute, prismatic, continuous, fixed.
        %
        % @type char
        Type
        
        % The rotation axis vector of the rigid joint
        %
        % @note it must be a 3x1 vector.
        %
        % @type rowvec
        Axis
        
        % The name of the child link
        %
        % @type char
        Child
        
        % The name of the parent link
        %
        % @type char
        Parent
        
        % A structure data stores the physical limits of the rigid joints
        %
        % Required fields of limit:
        % effort: the maximum actuator effort @type double
        % lower: the minimum allowable displacement @type double
        % upper: the maximum allowable displacement @type double
        % velocity: the maximum allowable velocity @type double
        % 
        % @type struct        
        Limit
        
        % A structure contains information about the actuator for the joint
        %
        % An empty property indicates the joint is not actuated.
        %
        % @type struct
        Actuator
        
    end
    
    properties (Hidden, SetAccess=protected, GetAccess=public)
        
        % The indices of kinematic chains from the base to the current
        % joint
        %
        % @type rowvec
        ChainIndices
        
        % The twist from the base frame
        %
        % @type rowvec
        Twist
        
        % The twist pairs of all precedent joints (coordinate frame)
        %
        % @type SymExpression
        TwistPairs
    end
    methods
        
        function obj = RigidJoint(varargin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %    Name: the name of the frame @type char
            %    Reference: the reference frame @type CoordinateFrame
            %    Offset: the offset of the origin @type rowvec
            %    R: the rotation matrix or the Euler angles @type rowvec
            %    Axis: the rotation axis vector @type rowvec
            %    Type: the type of the joints @type char
            %    Child: the child link frame @type RigidLink
            %    Limit: the joint physical limits @type struct
            
            
           
            
            % consruct the superclass object first
            obj = obj@CoordinateFrame(varargin{:});
            if nargin == 0
                return;
            end
            argin = struct(varargin{:});
            
            % validate and assign the joint type
            if isfield(argin, 'Type') && ~isempty(argin.Type)
                obj = obj.setType(argin.Type);
            else
                error('The joint type is not defined.');
            end
            
            % validate and assign the joint axis 
            if isfield(argin, 'Axis') && ~isempty(argin.Axis)
                obj = obj.setAxis(argin.Axis);
            elseif strcmp(obj.Type, 'fixed')
                obj = obj.setAxis([0,0,1]);
            else
                error('The joint rotation axis is not defined.');
            end
            
            
            % validate and assign the child link
            if isfield(argin, 'Child') && ~isempty(argin.Child)
                obj = obj.setChild(argin.Child);
            else
                error('The child link is not defined.');
            end
            
            % validate and assign the parent link
            if isfield(argin, 'Parent') && ~isempty(argin.Parent)
                obj = obj.setParent(argin.Parent);
            else
                error('The parent link is not defined.');
            end
            
            % validate and assign the physical limits
            if isfield(argin, 'Limit') && ~isempty(argin.Limit)
                obj = obj.setLimit(argin.Limit);
            else
                warning('The joint limits are not defined. Using default values.');
                default_limit = struct(...
                    'effort',0,...
                    'lower',-inf,...
                    'upper',inf,...
                    'velocity',inf);
                obj = obj.setLimit(default_limit);
            end
            
            % validate and assign the actuator info
            if isfield(argin, 'Actuator') && ~isempty(argin.Actuator)
                obj = obj.setActuator(argin.Actuator);
            end
        end
        
    end
    
    %% methods defined in external files
    methods
        obj = setAxis(obj, axis);
        
        obj = setType(obj, type);
        
        obj = setParent(obj, parent);
        
        obj = setChild(obj, child);
        
        obj = setLimit(obj, varargin);
        
        obj = setActuator(obj, varargin);
        
        obj = setChainIndices(obj, indices);
        
        xi = getTwist(obj);
        
        obj = computeTwist(obj);
        
        obj = setTwistPairs(obj, dofs, q);
    end
end