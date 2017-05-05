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
        Name
        
        
        % The parent reference coordinate frame
        %
        % @type CoordinateFrame
        Reference
        
        % The offset of the origin of the frame from the origin of the
        % reference frame
        %
        % @type rowvec
        Offset
        
        % The rotation matrix of the frame w.r.t. the reference frame
        %
        % @type matrix
        R
    end
    
    properties (Hidden, SetAccess=protected, GetAccess=public)
        % The homogeneous transformation from the base coordinate
        %
        % @type matrix
        gst0
        
    end
    
    methods
        
        function obj = CoordinateFrame(varargin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %    Name: the name of the frame @type char
            %    Reference: the reference frame @type CoordinateFrame
            %    Offset: the offset of the origin @type rowvec
            %    R: the rotation matrix or the Euler angles @type rowvec
            
            % if no input argument, create an empty object
            if nargin == 0
                return;
            end
            
            % update property values using the input arguments
            % load default values if not specified explicitly            
            argin = struct(varargin{:});
            
            
            % validate and assign the name
            if isfield(argin, 'Name')
                assert(ischar(argin.Name), 'The name must be a character array.');
            
                % validate name string
                
                obj.Name = argin.Name;
            else
                if ~isstruct(varargin{1})
                    error('The ''Name'' must be specified in the argument list.');
                else
                    error('The input structure must have a ''Name'' field');
                end
            end
            
            
            % validate and assign the reference frame
            if isfield(argin, 'Reference')
                obj = obj.setReference(argin.Reference);
            end
            
            % validate and assign the offset
            if isfield(argin, 'Offset')
                obj = obj.setOffset(argin.Offset);
            else
                warning('The offset vector is not defined. Using zero offset [0,0,0].');
                obj = obj.setOffset(zeros(1,3));
            end
            
            % validate and assign the Euler angles
            if isfield(argin, 'R')
                obj = obj.setRotationMatrix(argin.R);
            else
                warning('The rotation angles are not defined. Using zero angles [0,0,0].');
                obj = obj.setRotationMatrix(zeros(1,3));
            end
        end
        
        function obj = ToContactFrame(obj, type)
            % convert a coordinate frame into a contact frame
            %
            % Parameters:
            % type: the contact type @type char
            
            obj_struc = struct(...
                'Name', obj.Name,...
                'Reference', obj.Reference,...
                'R', obj.R,...
                'Offset',obj.Offset,...
                'Type',type);
            obj = ContactFrame(obj_struc);
        end
        
    end
    
    %% methods defined in external files
    methods
        obj = setReference(obj, ref);
        
        obj = setOffset(obj, offset);
        
        obj = setRotationMatrix(obj,r);
        
        obj = computeHomogeneousTransform(obj);
        
    end
    
    methods (Static)
        
        function gst = RPToHomogeneous(R,p)
            % Convert a rotation + translation to a homogeneous matrix
            
            gst = [R,p';
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