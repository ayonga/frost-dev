classdef ContactFrame < CoordinateFrame
    % A mechanical contact coordinate frame of a robot 
    %
    % @note We assume that the positive 'z' axis of the coordinate frame
    % is the normal axis of the contact.
    %
    % @note We assume the line contact is along the 'y' axis of the
    % coordinate frame.
    %
    % @note We use the terminology from Matt Mason's (CMU) lecture note.
    % see
    % http://www.cs.rpi.edu/~trink/Courses/RobotManipulation/lectures/lecture11.pdf   %
    % The following contact type is supported:
    % - 'PointContactWithFriction'
    % - 'PointContactWithoutFriction'
    % - 'LineContactWithFriction'
    % - 'LineContactWithoutFriction'
    % - 'PlanarContactWithFriction'
    % - 'PlanarContactWithoutFriction'
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (SetAccess=protected, GetAccess=public)
        % The contact type
        % 
        % @type char
        Type
        
    end
    
    properties (SetAccess=protected, GetAccess=public)
        
        
        % The wrench basis
        %
        % @note For the formal definition of wrench basis, please refer to
        % Chapter 5. of the "A Mathematical Introduction to Robotic
        % Manipulation" by Murray et al.
        %
        % @type matrix
        WrenchBase
        
        
    end
    
    
    methods
        
        
        function obj = ContactFrame(varargin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %    Name: the name of the frame @type char
            %    Reference: the reference frame @type CoordinateFrame
            %    Offset: the offset of the origin @type rowvec
            %    R: the rotation matrix or the Euler angles @type rowvec
            %    Type: the type of the contact @type char
            
            
            % consruct the superclass object first
            obj = obj@CoordinateFrame(varargin{:});
            if nargin == 0
                return;
            end
            
            argin = struct(varargin{:});
            
            % validate and assign the joint type
            if isfield(argin, 'Type')
                obj = obj.setType(argin.Type);
            else
                error('The contact type is not defined.');
            end
        end
            
        
        function obj = setType(obj, type)
            % Sets the contact type
            %
            % Parameters:
            % type: the contact type @type char
            
            
            valid_types = {'PointContactWithFriction',...
                'PointContactWithoutFriction',...
                'LineContactWithFriction',...
                'LineContactWithoutFriction',...
                'PlanarContactWithFriction',...
                'PlanarContactWithoutFriction'};
            
            obj.Type = validatestring(type,valid_types);
            
            I = eye(6);
            switch obj.Type
                case 'PointContactWithFriction'
                    % x, y, z
                    obj.WrenchBase = I(:,[1,2,3]);
                case 'PointContactWithoutFriction'
                    % z
                    obj.WrenchBase = I(:,3);
                case 'LineContactWithFriction'
                    % x, y, z, roll, yaw
                    obj.WrenchBase = I(:,[1,2,3,4,6]);
                case 'LineContactWithoutFriction'
                    % z, roll
                    obj.WrenchBase = I(:,[3,6]);
                case 'PlanarContactWithFriction'
                    % x, y, z, roll, pitch, yaw
                    obj.WrenchBase = I(:,[1,2,3,4,5,6]);
                case 'PlanarContactWithoutFriction'
                    % z, roll, pitch,
                    obj.WrenchBase = I(:,[3,4,5]);
            end
            
        end
        
        function FC = getFrictionCone(obj, f, mu, gamma)
            % returns the symbolic expression of the friction cone
            % constraints of the contact
            %
            % @note The friction cone constraints does not includes the
            % ZMP/CWS constraints.
            %
            % Parameters: 
            %  f: the SymVariable of the constraint wrenches
            %  @type SymVariable
            %  mu: the (static) coefficient of friction. @type double
            %  gamma: the coefficient of torsional friction @type double
            % 
            % Return values: 
            %  FC: symbolic expression of the friction cone 
            %  @type SymExpression
           
            assert(size(obj.WrenchBase,2) == length(f),...
                ['The dimension of the constraint wrenchs is incorrect.\n',...
                'Expected %d, instead %d'], size(obj.WrenchBase,2), length(f));
            
            assert(isreal(mu) && mu >= 0,...
                'The friction coefficient (mu) must be a positive real value.');
            
            assert(isreal(gamma) && gamma >= 0,...
                'The torsional friction coefficient (gamma) must be a positive real value.');
            
            switch obj.Type
                case 'PointContactWithFriction'
                    % x, y, z
                    FC = [f(3); % fz >= 0
                        f(1) + (mu/sqrt(2))*f(3);
                        -f(1) + (mu/sqrt(2))*f(3);
                        f(2) + (mu/sqrt(2))*f(3);
                        -f(2) + (mu/sqrt(2))*f(3)];
                case 'PointContactWithoutFriction'
                    % z
                    FC = f;
                case 'LineContactWithFriction'
                    % x, y, z, roll, yaw
                    FC = [f(3); % fz >= 0
                        f(1) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fx
                        -f(1) + (mu/sqrt(2))*f(3); % fx < mu/sqrt(2) * fz 
                        f(2) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fu
                        -f(2) + (mu/sqrt(2))*f(3); % fy < mu/sqrt(2) * fz
                        f(5) + gamma * f(3);       % -gamma * fz < wy
                        -f(5) + gamma * f(3)];     % wy < gamma * fz
                case 'LineContactWithoutFriction'
                    % z, roll
                    FC = f;
                case 'PlanarContactWithFriction'
                    % x, y, z, roll, pitch, yaw
                    FC = [f(3); % fz >= 0
                        f(1) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fx
                        -f(1) + (mu/sqrt(2))*f(3); % fx < mu/sqrt(2) * fz 
                        f(2) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fu
                        -f(2) + (mu/sqrt(2))*f(3); % fy < mu/sqrt(2) * fz
                        f(6) + gamma * f(3);       % -gamma * fz < wz
                        -f(6) + gamma * f(3)];     % wz < gamma * fz
                case 'PlanarContactWithoutFriction'
                    % z, roll, pitch,
                    FC = f;
            end
            
        end
        
        
        function zmp = getZMPConstraint(obj, f, la, lb, La, Lb)
            % returns the symbolic expression of the zero moment point
            % constraints of the contact
            %
            % @note For more detail, please refer to Eq. (28) and Fig. 3 in
            % this article: Grizzle, J. W.; Chevallereau, C.; Sinnet, R. W.
            % & Ames, A. D. Models, feedback control, and open problems of
            % 3D bipedal robotic walking. Automatica, 2014, 50, 1955 - 1988
            %
            % Parameters: 
            %  f: the SymVariable of the constraint wrenches
            %  @type SymVariable           
            %  la: the distance from the origin to the rolling edge along
            %  the negative y-axis  @type double
            %  lb: the distance from the origin to the rolling edge along
            %  the positive y-axis  @type double 
            %  La: the distance from the origin to the rolling edge along
            %  the negative x-axis  @type double
            %  Lb: the distance from the origin to the rolling edge along
            %  the positive x-axis  @type double
            % 
            % Return values: 
            %  zmp: symbolic expression of the ZMP constraints 
            %  @type SymExpression
            
            assert(size(obj.WrenchBase,2) == length(f),...
                ['The dimension of the constraint wrenchs is incorrect.\n',...
                'Expected %d, instead %d'], size(obj.WrenchBase,2), length(f));
            assert(isreal(la) && la >= 0,...
                'The distance (la) must be a positive real value.');
            assert(isreal(lb) && lb >= 0,...
                'The distance (lb) must be a positive real value.');
            
            if nargin > 4
                assert(isreal(La) && La >= 0,...
                    'The distance (La) must be a positive real value.');
                assert(isreal(Lb) && Lb >= 0,...
                    'The distance (Lb) must be a positive real value.');
            end
            
            
            switch obj.Type
                case 'PointContactWithFriction'
                    % x, y, z
                    zmp = []; % no zmp constraints
                case 'PointContactWithoutFriction'
                    % z
                    zmp = []; % no zmp constraints
                case 'LineContactWithFriction'
                    % x, y, z, roll, yaw
                    zmp = [la*f(3) - f(4);  % la*fz > mx
                        lb*f(3) + f(4)];    % mx > -lb*fz
                case 'LineContactWithoutFriction'
                    % z, roll
                    zmp = [la*f(1) - f(2);  % la*fz > mx
                        lb*f(1) + f(2)];    % mx > -lb*fz
                case 'PlanarContactWithFriction'
                    % x, y, z, roll, pitch, yaw
                    zmp = [la*f(3) - f(4);  % la*fz > mx
                        lb*f(3) + f(4);     % mx > -lb*fz
                        Lb*f(3) - f(5);     % Lb*fz > my
                        La*f(3) + f(5)];    % my > -La*fz
                case 'PlanarContactWithoutFriction'
                    % z, roll, pitch,
                    zmp = [la*f(3) - f(4);  % la*fz > mx
                        lb*f(3) + f(4);     % mx > -lb*fz
                        Lb*f(3) - f(5);     % Lb*fz > my
                        La*f(3) + f(5)];    % my > -La*fz
            end
            
        end
            
            
           
    end
end
    
    