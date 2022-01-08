classdef  (InferiorClasses = {?CoordinateFrame})  ContactFrame < CoordinateFrame & matlab.mixin.Copyable
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
        
        
        function obj = ContactFrame(argin)
            % The class constructor function
            %
            % Parameters:
            %  varargin: variable nama-value pair input arguments, in detail:
            %    Name: the name of the frame @type char
            %    Reference: the reference frame @type CoordinateFrame
            %    P: the offset of the origin @type rowvec
            %    R: the rotation matrix or the Euler angles @type rowvec
            %    Type: the type of the contact @type char
            
            arguments
                argin.Name char = ''
                argin.Reference = []
                argin.P (1,3) double {mustBeReal} = zeros(1,3)
                argin.R double {mustBeReal} = eye(3)
                argin.Type char = ''
                argin.AxIndices double = []
            end
            
            % consruct the superclass object first
            argin_sup = rmfield(argin,{'Type','AxIndices'});
            argin_cell = namedargs2cell(argin_sup);
            % consruct the superclass object first
            obj = obj@CoordinateFrame(argin_cell{:});
            
            
            % validate and assign the contact type
            if isfield(argin, 'Type')
                obj = obj.setType(argin.Type, argin.AxIndices);
            else
                error('The contact type is not defined.');
            end
        end
           
    end

    % methods defined in exteral files
    methods
        obj = setType(obj, type, ax_indices);

        [f_constr,label,auxdata] = getFrictionCone(obj, f, fric_coef);

        [f_constr, label, auxdata] = getZMPConstraint(obj, f, geometry)
    end
end
    
    