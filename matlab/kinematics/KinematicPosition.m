classdef KinematicPosition < Kinematics
    % Defines one of the three dimensional Cartesian positions of a fixed
    % point on a rigid link
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
        % @type integer
        axis
    end % properties
    
    
    methods
        
        function obj = KinematicPosition(name, model, parent, axis, varargin)
            % The constructor function
            %
            % Parameters:            
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char        
            %  model: the rigid body model @type RigidBodyModel
            %  parent: the name of the parent link on which this fixed
            %  position is rigidly attached @type char              
            %  axis: one of the (x,y,z) axis @type char
            %  offset: an offset of from the origin of the parent link
            %  frame @type rowvec @default [0,0,0]
            %  linear: indicates whether linearize the original
            %  expressoin @type logical
            
            if nargin == 0
                name = [];
            end
            obj = obj@Kinematics(name);
            
            
            if nargin > 2
                
                if isa(model,'RigidBodyModel')
                    valid_links = {model.links.name};
                else
                    error('Kinematics:invalidType',...
                        'The model has to be an object of RigidBodyModel class.');
                end
                % parse inputs
                valid_axis = {'x','y','z'};
                default_offset = [0,0,0];
                
                p = inputParser();
                p.addRequired('parent', @(x) any(validatestring(x,valid_links)));
                p.addRequired('axis', @(x) any(validatestring(axis,valid_axis)));
                p.addOptional('offset', default_offset, @(x) validateattributes(x,{'numeric'},{'size',[1,3]}));
                p.addParameter('linear', obj.linear, @islogical);
                
                parse(p, parent, axis, varargin{:});
                
                obj.parent = p.Results.parent;
                obj.axis   = find(strcmpi(p.Results.axis, valid_axis));
                obj.offset = p.Results.offset;
                obj.linear = p.Results.linear;
            
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
            cmd = ['{ComputeCartesianPositions[',cell2tensor(arg),'][[1,',num2str(obj.axis),']]}'];
        end
        
        % use default function
        % function cmd = getJacMathCommand(obj)
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
