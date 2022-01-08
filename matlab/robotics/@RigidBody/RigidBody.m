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
        Mass (1,1) double
        
        % The inertia of the rigid link
        %
        % @type matrix
        Inertia (3,3) double
        
        
    end
    
    properties (Dependent)
        % The spatial inertia of the rigit link
        %
        % @type matrix
        SpatialInertia
    end
    
    methods
        
        
        function obj = RigidBody(argin)
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
            
            arguments
                argin.Name char = ''
                argin.Reference = []
                argin.P (1,3) double {mustBeReal} = zeros(1,3)
                argin.R double {mustBeReal} = eye(3)
                argin.Mass (1,1) double {mustBeReal, mustBeNonnegative, mustBeNonNan} = 0
                argin.Inertia (3,3) double {mustBeReal, mustBeNonNan} = zeros(3)
            end
            argin_sup = rmfield(argin,{'Mass','Inertia'});
            argin_cell = namedargs2cell(argin_sup);
            % consruct the superclass object first
            obj = obj@CoordinateFrame(argin_cell{:});
            
            obj.Mass = argin.Mass;
            obj.Inertia = argin.Inertia;
            
            
        end
        
        
        
        
        
        function G = get.SpatialInertia(obj)
            G = [...
                obj.Mass*eye(3), zeros(3); 
                zeros(3),        obj.Inertia];
        end
        
    end
    
    %% methods defined in external files
    methods
        
        obj = setMass(obj, mass);
        
        obj = setInertia(obj, inertia);
    end
end
