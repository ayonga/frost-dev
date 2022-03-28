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
        
        
        % The twist axis of the joint in the body (joint) frame
        %
        % @type rowvec
        TwistAxis
        
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
        
        % The objects of the following joints
        %
        % @type array
        ChildJoints 
        
        ChildJointIndices
        
    end
    
    properties (Hidden, SetAccess=public, GetAccess=public)
        
        q (1,1) double
        
        dq (1,1) double
        
        ddq (1,1) double
        
        V (6,1) double
        
        dV (6,1) double 
        
        Vm (6,1) double
        
        dVm (6,1) double
        
        G (6,6) double  
        
        Gm (6,6) double
        
        F (6,1) double
        
    end
    
    properties (Hidden, SetAccess=protected, GetAccess=public)
        
        % The indices of kinematic chains from the base to the current
        % joint
        %
        % @type rowvec
        ChainIndices
                
        % The twist pairs of all precedent joints (coordinate frame)
        %
        % @type SymExpression
        TwistPairs
    end
    
    properties (Hidden, Dependent)
        
        % The twist axis of the joint in the spatial (world) frame
        %
        % @type rowvec
        SpatialTwistAxis
        
    end
    
    
    methods
        function obj = updateTwistAxis(obj)
            % returns the twist vector of the rigid joint
            %
            %
            
            
            switch obj.Type
                case 'prismatic'
                    obj.TwistAxis = transpose([obj.Axis,zeros(1,3)]);
                case {'revolute','continuous'}
                    obj.TwistAxis = transpose([zeros(1,3),obj.Axis]);
                case 'fixed'
                    obj.TwistAxis = zeros(6,1);
                otherwise
                    obj.TwistAxis = nan(6,1);
            end
            
            
        end
        
        function xi_s = get.SpatialTwistAxis(obj)
            % computes the twist from the base frame
            %
            
            xi_b = obj.TwistAxis;
            
            if isempty(obj.T0)
                error('Please defined the transformation parameters (R,p) first.');
            else
                adj = CoordinateFrame.RigidAdjoint(obj.T0);
                xi_s = transpose(adj*xi_b);
            end
            
        end
        
    end
    
    
    
    methods
        
        function obj = RigidJoint(argin)
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
            
            arguments
                argin.Name char = ''
                argin.Reference = []
                argin.P (1,3) double {mustBeReal} = zeros(1,3)
                argin.R double {mustBeReal} = eye(3)
                argin.Type char {mustBeMember(argin.Type, {'','prismatic', 'revolute', 'continuous', 'fixed'})} = ''
                argin.Axis double {mustBeReal} = nan(1,3)
                argin.Child char = ''
                argin.Parent char = ''
                argin.Limit struct = struct()
                argin.Actuator struct = struct()
            end
           
            argin_sup = rmfield(argin,{'Type','Axis','Child','Parent','Limit','Actuator'});
            argin_cell = namedargs2cell(argin_sup);
            % consruct the superclass object first
            obj = obj@CoordinateFrame(argin_cell{:});
                  
            
            obj.Type = argin.Type;            
            obj = obj.setAxis(argin.Axis);
            obj.Child = argin.Child;
            obj.Parent = argin.Parent;
            
                      
            % validate and assign the physical limits
            if ~isempty(fieldnames(argin.Limit))
                limits = namedargs2cell(argin.Limit);
                obj = obj.setLimit(limits{:});
            else
                %                 warning('The joint limits are not defined. Using default values.');
                default_limit = struct(...
                    'effort',0,...
                    'lower',-inf,...
                    'upper',inf,...
                    'velocity',inf);
                %                 display(default_limit);
                limits = namedargs2cell(default_limit);
                obj = obj.setLimit(limits{:});
            end
            
            % validate and assign the actuator info
            if ~isempty(fieldnames(argin.Actuator))
                acts = namedargs2cell(argin.Actuator);
                obj = obj.setActuator(acts{:});
            end
        end
        
    end
    
    %% methods defined in external files
    methods
        obj = setAxis(obj, axis);
                
        obj = setLimit(obj, param);
        
        obj = setActuator(obj, param);
        
        obj = setChainIndices(obj, indices);
        
        obj = computeTwist(obj);
        
        obj = setTwistPairs(obj, dofs, q);
        
        obj = addChildJoints(obj, joint, joint_index);
    end
end