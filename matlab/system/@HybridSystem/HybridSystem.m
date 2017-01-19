classdef HybridSystem
    % HybridSystem defines a hybrid dynamical system that has both
    % continuous and discrete dynamics, such as bipedal locomotion.
    %
    % This class provides basic elements and functionalities of a hybrid
    % dynamicsl system. The mathematical definition of the hybrid system is
    % given as
    % \f{eqnarray*}{
    % \mathscr{HC} = \{\Gamma, \mathcal{D}, U, S, \Delta, FG\}
    % \f}
    %
    % The implementation of the hybrid system class is heavily based on the
    % Matlab's digraph data type, with wrapper functions with additional
    % validation.
    %
    % @author Ayonga Hereid @date 2016-09-26
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
   
    
    %% public properties
    properties (GetAccess = public, SetAccess = protected)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        Name
        
        % The directed graph that describes the hybrid dynamical system
        % structure
        %
        % @type digraph
        Gamma
        
        % The rigid body model of the hybrid system
        %
        % @type RigidBodyModel
        Model
        
        % The hybrid flows (trajectory) recorder
        %
        % @type cell
        Flow
        
               
        
        
        
    end
    
    

    
    properties (Dependent, Hidden)
        % A structure describes the name, type, attributes, and
        % default value of each properties of the vertex
        %
        % @type struct
        VertexProperties
        
        % A structure describes the name, type, attributes, and
        % default value of each properties of the edge
        %
        % @type struct
        EdgeProperties
    end
    methods
        function VertexProperties = get.VertexProperties(obj)
            
            VertexProperties = struct();
            VertexProperties.Name =  {'Domain','Control','Param'};
            VertexProperties.Type = {{'Domain'},{'Controller'},{'struct'}};
            VertexProperties.Attribute = {{},{},{}};
            VertexProperties.DefaultValue =  {{[]},{[]},{[]}};
        end
        
        function EdgeProperties = get.EdgeProperties(obj)
            
            EdgeProperties = struct();
            EdgeProperties.Name =  {'Guard', 'Weights'};
            EdgeProperties.Type = {{'Guard'}, {'numeric'}};
            EdgeProperties.Attribute = {{}, {'scalar'}};
            EdgeProperties.DefaultValue = {{[]}, NaN};
        end
    end
    
    %% Public methods
    methods (Access = public)
        function obj = HybridSystem(name, model)
            % the default calss constructor
            %
            % Parameters:
            % varargin: variable class construction arguments.
            %
            % Return values:
            % obj: the class object
            
            assert(ischar(name), 'The object name must be a string.');
            obj.Name = name;
            
            assert(isa(model, 'RigidBodyModel'), ...
                'The model must be an object of ''RigidBodyModel''.');
            obj.Model = model;
            
            % initialize an empty directed graph with specified properties           
            obj.Gamma = digraph;
            % add a dummy node and remove it to initialize the properties
            obj = addVertex(obj,'dummy');
            obj = rmVertex(obj,'dummy');
            
        end
        
        
        
        
        
        
        
        
        
        
        
    end
        
    %% methods defined in separate files
    methods
        obj = addVertex(obj, varargin);
        
        obj = addEdge(obj, varargin);
        
        obj = rmVertex(obj, varargin);
        
        obj = rmEdge(obj, varargin);
        
        obj = setEdgeProperties(obj, s, t, varargin);
        
        obj = setVertexProperties(obj, vertex, varargin);
        
        [dx, extra] = calcDynamics(obj, t, x, cur_node);
        
        [value, isterminal, direction] = checkGuard(obj, t, x, cur_node, assoc_edges);
        
        obj = simulate(obj, options);
    end
    
    %% Private methods
    methods (Static, Access=private)
        function validatePropAttribute(value, type, attribute)
            
            if iscell(value)
                cellfun(@(x)validateattributes(x,type,attribute), value);
            elseif isnumeric(value)
                % if a property is a numeric value, it must be a row vector
                for i=1:size(value,1)
                    validateattributes(value(i,:),type,attribute);
                end
            else
                error('The input argument must be a cell array of objects.');
            end
            
        end
    end
    
    
end

