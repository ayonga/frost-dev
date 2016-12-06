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
    
    properties (SetAccess=protected, GetAccess=public)
        % The parent link name of the body frame
        %
        % @type char
        Parent
        
        % The (x,y,z)-axis of the rotation
        %
        % @type char
        Axis
        
        
        % The indices of the degrees of freedom
        %
        % @type rowvec
        cIndex
        
    end % properties
    
    
    
    
    
    methods
        
        function obj = KinematicOrientation(name, model, parent, axis, varargin)
            % The constructor function
            %
            % Parameters:            
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char        
            %  model: the rigid body model @type RigidBodyModel
            %  parent: the name of the parent link on which this fixed
            %  position is rigidly attached @type char             
            %  axis: one of the (x,y,z) axis @type char   
            %  varargin: superclass options @type varargin
            
            
            obj = obj@Kinematics(name, varargin{:});
            
            % the dimension is always 1
            obj.Dimension = 1;
            
            
            if nargin > 1
                % check valid model object
                if isa(model,'RigidBodyModel')
                    valid_links = {model.links.name};
                else
                    error('Kinematics:invalidType',...
                        'The model has to be an object of RigidBodyModel class.');
                end
                
                % assign the parent link name (case insensitive)
                obj.Parent  = validatestring(parent,valid_links);    
                
                
                % set direction axis
                valid_axis = {'x','y','z'};
                obj.Axis = validatestring(axis,valid_axis);
                obj.cIndex = 3 + find(strcmpi(obj.Axis, valid_axis));
            end
            
            
        end
        
        
        
        
    end % methods
    
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            % create a cell as the input argument, use zero offsets
            arg = {obj.Parent,[0,0,0]};
            % class specific command for computing orientation based kinematic constraint
            cmd = ['ComputeSpatialPositions[',cell2tensor(arg),'][[1,{',num2str(obj.cIndex),'}]]'];
        end
        
        % overload the Jacobian compilation command
        function cmd = getJacMathCommand(obj)
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint's Jacobian.
            
            % create a cell as the input argument, use zero offsets
            arg = {obj.Parent,[0,0,0]};
            % class specific command for computing rotational spatial Jacobian of an orientation
            cmd = ['ComputeSpatialJacobians[',cell2tensor(arg),'][[1,{',num2str(obj.cIndex),'}]]'];
        end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
