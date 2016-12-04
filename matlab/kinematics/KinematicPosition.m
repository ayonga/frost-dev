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
    
    properties (SetAccess=protected, GetAccess=public)
        % The name of the rigid link on which the point is attached to
        %
        % @type char
        parent
        
        % The 3-dimensional offset of the point in the body joint
        % coordinates that is rigidly attached to parent link
        %
        % @type rowvec
        offset
        
        % The (x,y,z)-axis index of the position
        %
        % @type char
        axis
        
        % The indices of the degrees of freedom
        %
        % @type integer        
        c_index
    end % properties
    
    
    
    methods
        
        function obj = KinematicPosition(name, model, parent, offset, axis, varargin)
            % The constructor function
            %
            % Parameters:            
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char        
            %  model: the rigid body model @type RigidBodyModel
            %  parent: the name of the parent link on which this fixed
            %  position is rigidly attached @type char                     %  
            %  offset: an offset of from the origin of the parent link
            %  frame @type rowvec @default [0,0,0]
            %  axis: one of the (x,y,z) axis @type char
            %  varargin: superclass options @type varargin
            %
            % See also: Kinematics
            
            
            obj = obj@Kinematics(name, varargin{:});
            
            % the dimension is always 1
            obj.dimension = 1;
            
            if nargin > 1
                % check valid model object
                if isa(model,'RigidBodyModel')
                    valid_links = {model.links.name};
                else
                    error('Kinematics:invalidType',...
                        'The model has to be an object of RigidBodyModel class.');
                end
                
                % assign the parent link name (case insensitive)
                obj.parent  = validatestring(parent,valid_links);    
                
                % set point offset
                if isnumeric(offset) && length(offset)==3
                    if size(offset,1) > 1 % column vector
                        % convert to row vector
                        obj.offset = offset';
                    else
                        obj.offset = offset;
                    end                        
                end
               
                
                % set direction axis
                valid_axis = {'x','y','z'};
                obj.axis = validatestring(axis,valid_axis);
                
                obj.c_index = find(strcmpi(obj.axis, valid_axis));
            end
           
            
        end
        
        
        
        
    end % methods
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            
            % create a cell as the input argument
            arg = {obj.parent,obj.offset};
            % command for rigid position
            cmd = ['{ComputeSpatialPositions[',cell2tensor(arg),'][[1,',num2str(obj.c_index),']]}'];
        end
        
        % overload the Jacobian compilation command
        function cmd = getJacMathCommand(obj)
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint's Jacobian.
            
            % create a cell as the input argument
            arg = {obj.parent,obj.offset};
            % class specific command for computing rotational spatial
            % Jacobian of an position
            cmd = ['{ComputeSpatialJacobians[',cell2tensor(arg),'][[1,',num2str(obj.c_index),']]}'];
        end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
