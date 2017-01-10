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
    
   
    
    properties (GetAccess = public, SetAccess = protected)
        % The directed graph that describes the hybrid dynamical system
        % structure
        %
        % @type digraph
        Gamma
    
    end
    
    
    %% public properties
    properties (GetAccess = public, SetAccess = protected)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        Name
        
        
        
        
        
        % The rigid body model of the hybrid system
        %
        % @type RigidBodyModel
        Model
        
        % The hybrid flows (trajectory) recorder
        %
        % @type cell
        Flow
        
               
        
        % The class option
        %
        % Required fields of options:
        %  sim_options: the simulation options @type struct
        %  ode_options: the default options for ODE solvers
        %
        % Required fields of sim_options:
        %  num_cycle: the number of cyclic motion of the periodic directed
        %          cycle @type integer @default 1
        %  first_vertex: the starting vertex in the graph
        %
        % @type struct
        Options = struct(...
            'sim_options',[],...
            'ode_options',[]);
        
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
            EdgeProperties.Name =  {'Guard', 'Direction', 'Weights'};
            EdgeProperties.Type = {{'char'}, {'numeric'}, {'numeric'}};
            EdgeProperties.Attribute = {{'scalartext'},{'<=',1,'>=',-1,'integer'},{'scalar'}};
            EdgeProperties.DefaultValue = {'',1,NaN};
        end
    end
    
    %% Public methods
    methods (Access = public)
        function obj = HybridSystem(varargin)
            % the default calss constructor
            %
            % Required fields of options:
            %  sim_options: the simulation options @type struct     
            %  ode_options: the default options for ODE solvers
            %
            % Required fields of sim_options:
            %  num_cycle: the number of cyclic motion of the periodic directed
            %          cycle @type integer @default 1
            %
            % Parameters:
            % varargin: variable class construction arguments.
            %
            % Return values:
            % obj: the class object
            
            
            % initialize an empty directed graph with specified properties           
            obj.Gamma = digraph;
            % add a dummy node and remove it to initialize the properties
            %             empty_props = cell(numel(obj.VertexProperties.Name),1);
            %             dummy_node = cell2table([{'dummy'},empty_props(:)'],'VariableNames',[{'Name'},obj.VertexProperties.Name]);
            %             obj.Gamma = addnode(obj.Gamma,dummy_node);
            %             obj.Gamma = rmnode(obj.Gamma,'dummy');
            obj = addVertex(obj,'dummy');
%             obj = addEdge(obj,'Source',{'dummy'},'Target',{'dummy'});
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

