classdef HybridSystem < handle & matlab.mixin.Copyable
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
        function VertexProperties = get.VertexProperties(~)
            
            VertexProperties = struct();
            VertexProperties.Name =  {'Domain','Control','Param','IsTerminal'};
            VertexProperties.Type = {{'ContinuousDynamics'},{'Controller'},{'struct'},{'logical'}};
            VertexProperties.Attribute = {{},{},{},{'nonempty'}};
            VertexProperties.DefaultValue =  {{[]},{[]},{[]},false};
        end
        
        function EdgeProperties = get.EdgeProperties(~)
            
            EdgeProperties = struct();
            EdgeProperties.Name =  {'Guard', 'Param', 'Weights'};
            EdgeProperties.Type = {{'DiscreteDynamics'}, {'struct'}, {'numeric'}};
            EdgeProperties.Attribute = {{}, {}, {'scalar'}};
            EdgeProperties.DefaultValue = {{[]},{[]}, NaN};
        end
    end
    
    %% Public methods
    methods (Access = public)
        function obj = HybridSystem(name)
            % the default calss constructor
            %
            % Parameters:
            % name: the name of the hybrid system model @type char
            %
            % Return values:
            % obj: the class object
            
            assert(ischar(name), 'The object name must be a character vector.');
            obj.Name = name;
            
            
            % initialize an empty directed graph with specified properties           
            obj.Gamma = digraph;
            % add a dummy node and remove it to initialize the properties
            obj = addVertex(obj,'dummy');
            obj = rmVertex(obj,'dummy');
            
        end
        
        
        function ret = isDirectedCycle(obj)
            % returns true if the underlying directed graph is a simple
            % directed cycle.
            %
            % A simple directed cycle is a directed graph that has uniform
            % in-degree 1 and uniform out-degree 1.
            
            g = obj.Gamma;
            
            ret = all(indegree(g)==1) && all(outdegree(g)==1);
            
        end
        
        
        
        function sys = subGraph(obj, nodeIDs)
            % extract the subgraph of the hybrid system to create a new
            % hybrid system object with the same name
            %
            % Parameters:
            % nodeIDs: the node ids of the subgraph
            
            sys = HybridSystem(obj.Name);
            
            sub_g = subgraph(obj.Gamma, nodeIDs);
            
            sys.Gamma = sub_g;
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
        
        obj = simulate(obj, t0, x0, tf, options, varargin);
    end
    
    %% Private methods
    methods (Static, Access=private)
        function validatePropAttribute(name, value, type, attribute)
            
            if iscell(value)
                cellfun(@(x)validateattributes(x,type,attribute,...
                    'HybridSystem', name), value);
            elseif isnumeric(value)
                % if a property is a numeric value, it must be a row vector
                for i=1:size(value,1)
                    validateattributes(value(i,:),type,attribute,'HybridSystem', name);
                end
            else
                error('The input argument must be a cell array of objects.');
            end
            
        end
    end
    
    
end

