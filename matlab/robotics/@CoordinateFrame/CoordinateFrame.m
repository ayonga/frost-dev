classdef CoordinateFrame < handle
    % A kinematic coordinate frame class
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (SetAccess=protected, GetAccess=public)
        % The name of the coordinate frame
        %
        % @type char
        Name char        
        
        % The parent reference coordinate frame
        %
        % @type CoordinateFrame
        Reference CoordinateFrame
        
        % The position vector of the frame origin in the reference frame
        %
        % @type rowvec
        P (1,3) double = zeros(1,3)
        
        % The orientation of the frame in the reference frame
        %
        % @type matrix
        R (3,3) double = eye(3)
    end
    
    properties (SetAccess=protected, GetAccess=public, Hidden)
        % The homogeneous transformation matrix of the frame w.r.t. the
        % reference frame
        %
        % @type matrix
        T (4,4) double
        
        % The homogeneous transformation matrix of the reference frame
        % w.r.t. this frame
        %
        % @type matrix
        Tinv (4,4) double
        
        % The homogeneous transformation from the world coordinate at the
        % home position (i.e., q=0)
        %
        % @type matrix
        T0 (4,4) double
        
        % The homogeneous transformation to the world coordinate at the
        % home position (i.e., q=0)
        %
        % @type matrix
        T0inv (4,4) double
    end
    
    
    
    
    
    methods
        
        function obj = CoordinateFrame(argin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %    Name: the name of the frame @type char
            %    Reference: the reference frame @type CoordinateFrame
            %    Offset: the offset of the origin @type rowvec
            %    R: the rotation matrix or the Euler angles @type rowvec
            
            arguments
                argin.Name char = ''
                argin.Reference = []
                argin.P double {mustBeReal} = zeros(1,3)
                argin.R double {mustBeReal} = eye(3)
            end
            
            obj.Name = argin.Name;
            
            obj.setOffset(argin.P);
            obj.setRotationMatrix(argin.R);
            
            
            if ~isempty(argin.Reference)
                assert(isa(argin.Reference,'CoordinateFrame'),...
                    'The reference frame must be a CoordinateFrame object.');
                obj.Reference = argin.Reference;
            end
                       
            obj.updateTransform();
            
        end
        
        function obj = ToContactFrame(obj, type)
            % convert a coordinate frame into a contact frame
            %
            % Parameters:
            % type: the contact type @type char
            
            obj_args = namedargs2cell(struct(...
                'Name', obj.Name,...
                'Reference', obj.Reference,...
                'R', obj.R,...
                'P',obj.P,...
                'Type',type));
            
            obj = ContactFrame(obj_args{:});
        end
        
        function obj = updateTransform(obj)
            
            
            
            obj.T = CoordinateFrame.RPToHomogeneous(obj.R, obj.P);
            obj.Tinv = CoordinateFrame.RigidInverse(obj.T);
            
            if isempty(obj.Reference)
                gst_0 = eye(4);
            else
                gst_0 = obj.Reference.T0;
            end
            
            obj.T0 = gst_0*obj.T;
            obj.T0inv = CoordinateFrame.RigidInverse(obj.T0);
        end
        
    end
    
    
    
    methods (Static)
        
        function gst = RPToHomogeneous(R,p)
            % Convert a rotation + translation to a homogeneous matrix
            if isrow(p)
                p = p';
            end
            gst = [R,p;
                zeros(1,3),1];
        end
        
        function adj = RigidAdjoint(g)
            % rigid adjoint matrix from the homonegeous matrix
            
            R = CoordinateFrame.RigidOrientation(g);
            p = CoordinateFrame.RigidPosition(g);
            
            s = CoordinateFrame.AxisToSkew(p);
            
            adj = [R, s*R;
                zeros(3), R];
        end
       
        function gst = RigidInverse(g)
            R = CoordinateFrame.RigidOrientation(g);
            p = CoordinateFrame.RigidPosition(g);
            
            if isa(p,'SymExpression')
                gst = [transpose(R),-transpose(R)*tomatrix(p);
                    zeros(1,3),1];
            else
                gst = [transpose(R),-transpose(R)*p;
                    zeros(1,3),1];
            end
        end
        
        function R = RigidOrientation(g)
            % extract the rigid orientation from the homogeneous
            % transformation matrix
            
            [nc,nr] = size(g);
            
            assert(nc==nr && nc==4,'Wrong matrix dimension');
            
            R = g(1:nr-1,1:nc-1);
        end
        
        function p = RigidPosition(g)
            % extract the rigid position from the homogeneous
            % transformation matrix
            
            [nc,nr] = size(g);
             
            assert(nc==nr && nc==4,'Wrong matrix dimension');
            
            p = g(1:nr-1,nc);
        end
        
        function s = AxisToSkew(p)
            % converts the axis vector to a skew matrix
            
            assert(isvector(p) && length(p)==3,...
                'The axis vector must be a 3x1 vector.');
            
            s = [0,-p(3),p(2);
                p(3),0,-p(1);
                -p(2),p(1),0];
        end
        
        function adV = LieBracket(V)
            % the notation is different from the MR book.
            assert(isvector(V) && length(V)==6,...
                'The twist vector must be a 6x1 vector.');
            
            v = V(1:3);
            w = V(4:6);
            v_bracket = CoordinateFrame.AxisToSkew(v);
            w_bracket = CoordinateFrame.AxisToSkew(w);
            adV = [w_bracket, v_bracket; zeros(3), w_bracket];
        end
        
        function T = TwistExp(V, theta)
            assert(isvector(V) && length(V)==6,...
                'The twist vector must be a 6x1 vector.');
            assert(isscalar(theta),...
                'The theta must be a scalar.');
            
            v = V(1:3);
            w = V(4:6);
            
            if isrow(v)
                v = v';
            end
            if isrow(w)
                w = w';
            end
            if isa(theta,'SymExpression')
                if norm(w) == 0 % w = [0,0,0]
                    R = eye(3);
                    p = tomatrix(theta)*v;
                else
                    R = CoordinateFrame.SkewExp(w,theta);
                    S = CoordinateFrame.AxisToSkew(w);
                    %                     p = (tomatrix(theta)*eye(3) + tomatrix((1-cos(theta))) * S + tomatrix(theta-sin(theta)) * (S * S)) * v;
                    p = (eye(3) - R)*S*v + w*(transpose(w)*v)*theta;
                end
            else
                if norm(w) == 0 % w = [0,0,0]
                    R = eye(3);
                    p = theta.*v;
                else
                    R = CoordinateFrame.SkewExp(w,theta);
                    S = CoordinateFrame.AxisToSkew(w);
                    p = (eye(3) - R)*S*v + w*(transpose(w)*v)*theta;
                end
            end
            T = CoordinateFrame.RPToHomogeneous(R,p);
        end
        
        function R = SkewExp(v, theta)
            
            assert(isvector(v) && length(v)==3,...
                'The twist vector must be a 3x1 vector.');
            assert(isscalar(theta),...
                'The theta must be a scalar.');
            
            S = CoordinateFrame.AxisToSkew(v);
            if isa(theta,'SymExpression')
                R = eye(3) + tomatrix(sin(theta))*S + tomatrix(1-cos(theta)) * (S * S);
            else
                R = eye(3) + sin(theta)*S + (1-cos(theta)) * (S * S);
            end
        end
    end
    
    %% The following methods are not fast enough compared to counterpart Mathematica implementation.
    %% They should be only used fot testing/prototyping.
    methods
        
        pos = computeCartesianPosition(obj, p);
        
        rpy = computeEulerAngle(obj);
        
        g = computeForwardKinematics(obj);
            
        Jac = computeBodyJacobian(obj, nDof);
        
        Jac = computeSpatialJacobian(obj, nDof);
        
        c_str = getTwists(obj, p);
    end
    
    
end
