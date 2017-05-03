classdef RigidBody < CoordinateFrame
    % A coordinate frame that is rigidly attached to the CoM position of
    % a rigid link. In addition, this class also stores the mass and
    % inertia of the rigid link to which the frame is attached.
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (SetAccess=protected, GetAccess=public)
        % The mass of the rigid link
        %
        % @type double
        Mass
        
        % The inertia of the rigid link
        %
        % @type matrix
        Inertia
        
        
    end
    
    
    methods
        
        
        function obj = RigidBody(varargin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %    Name: the name of the frame @type char
            %    Reference: the reference frame @type CoordinateFrame
            %    Offset: the offset of the origin @type rowvec
            %    R: the rotation matrix or the Euler angles @type rowvec
            %    Mass: the mass of the link @type double
            %    Inertia: the inertia of the link @type matrix
            
            
            
            
            % consruct the superclass object first
            obj = obj@CoordinateFrame(varargin{:});
            if nargin == 0
                return;
            end
            argin = struct(varargin{:});
            
            % validate and assign the link mass
            if isfield(argin, 'Mass')
                obj = obj.setMass(argin.Mass);
            else
                warning('The mass is not defined. Using zero mass.');
                obj = obj.setMass(0);
            end
            
            % validate and assign the joint inertia 
            if isfield(argin, 'Inertia')
                obj = obj.setInertia(argin.Inertia);
            else
                warning('The inertia matrix is not defined. Using zero inertia matrix.');
                obj = obj.setInertia(zeros(3));
            end
            
        end
        
        
        
        
        
            
        
    end
    
    %% methods defined in external files
    methods
        
        obj = setMass(obj, mass);
        
        obj = setInertia(obj, inertia);
    end
end