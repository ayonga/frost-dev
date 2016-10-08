classdef DirectedGraph
    % DirectedGraph defines a simple direct graph class
    % 
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
    
    %% Public properties
    properties (Access = public)
    end
    
    %% Constant properties
    properties (Constant)
        
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)        
        
        
        
        % A struct describes the edges in the directed graph
        %
        % @type struct
        edges
                
        % A string list describes the vertices (nodes) in the directed graph
        %
        % @type cell
        vertices
        
        % The class option
        %
        % Required fields of options:
        %  isPeriodic: indicates whether the graph is periodic or not @type
        %  logical @defaul true
        %
        % @type struct
        options = struct(...
            'isPeriodic',true);
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = DirectedGraph(vertices, edges, options)
            % The class constructor function that configure the structure
            % of the directed graph
            % 
            %
            % Parameters:
            %  vertices: the list of vertices @type cell
            %  edges: the source-target vertex pairs @type
            %  varargin: optional input arguments.
            %    options: the graph options @type struct @default []
            %
            % Return values:
            %  obj: the instantiated object
            
            % check input arguments
            assert(iscell(vertices) && iscell(edges),...
                'The input arguments vertices/edges must be a cell.');
            
            % assign the object options
            if nargin > 2 
                obj.options = struct_overlay(obj.options, options);
            end
            
            
            obj.vertices = vertices;
            
            
            %| @note If the edges are not provided, we assume the graph is
            % unidirectional.
            if isempty(edges)
                
                if obj.options.isPeriodic
                    source = vertices;
                    target = [vertices(2:end),vertices(1)];
                else                    
                    source = vertices(1:end-1);
                    target = vertices(2:end);
                end
                num_edges = numel(source);
                edge_name = cell(1,num_edges);
                for i=1:num_edges
                    edge_name{i} = ['e',num2str(i)];
                end
            else
                edge_name = edges{1};
                source = edges{2};
                target = edges{3};
                if obj.options.isPeriodic
                    assert(numel(source) == numel(target),...
                        'The periodic graph requires the number of target and source vertices are equal.');
                    assert(strcmp(source{1},target{end}),...
                        ['The periodic graph requires the first vertex in the source vertices list ',... 
                        'is the same as the last vertex of in the target vertices list.']);
                end
            end
            
            
            
            
            
            % obj.edges = table(transpose(source), transpose(target));
            
            obj.edges = struct(...
                'name',edge_name,...
                'source', source,...
                'target', target);
            
            
        end
        
        function edge = getEdgeBySource(obj, source_vertex)
            % Get the name of edges whose source is the same as the
            % 'source_vertex'
            %
            % Parameters:
            %  source_vertex: the source vertex name @type char
            %
            % Return values:
            %  edge: the name of corresponding edges @type cell
            
            % find the rows whose 'source' is the 'source_vertex'
            rows = strcmp({obj.edges.source},source_vertex);
            
             % extract the target vertex using the row indexing
            if any(rows)
                edge = {obj.edges(rows).name};
            else
                edge = [];
                warning('There is no source vertex exists for %s\n',source_vertex);
            end
            
        end
        
        function edge = getEdgeByTarget(obj, target_vertex)
            % Get the name of edges whose target is the same as the
            % 'target_vertex'
            %
            % Parameters:
            %  target_vertex: the target vertex name @type char
            %
            % Return values:
            %  edge: the name of corresponding edges @type cell
            
            % find the rows whose 'source' is the 'source_vertex'
            rows = strcmp({obj.edges.target},target_vertex);
            
             % extract the target vertex using the row indexing
            if any(rows)
                edge = {obj.edges(rows).name};
            else
                edge = [];
                warning('There is no target vertex exists for %s\n',target_vertex);
            end
            
        end
        
        %         function obj = setStartingVertex(obj, vertex)
        %             % Set the non-default starting vertex of the graph
        %             %
        %             % Parameters:
        %             %  vertex: the name of the starting vertex @type char
        %             %
        %             % @see configureGraph
        %
        %             % check if graph has been configured priori
        %             assert(~isempty(obj.vertices) || ~isempty(obj.edges),...
        %                 'The graph is empty, please configure the graph first.');
        %
        %             % check if the given vertex name exists in the graph
        %             assert(any(strcmp(obj.vertices,vertex)),...
        %                 'The vertex %s does not exist in the graph.',vertex);
        %
        %             obj.sVertex = vertex;
        %         end
            
            
        
        function target = getTarget(obj, source_vertex)
            % Returns the name of target vertex of the given source vertex
            %
            % Parameters:
            %  source: the name of the source vertex @type char
            %
            % Return values:
            %  target: the name of the target vertex @type char
            
            % find the rows whose 'source' is the 'source_vertex'
            rows = strcmp({obj.edges.source},source_vertex);
            
             % extract the target vertex using the row indexing
            if any(rows)
                target = {obj.edges(rows).target};
            else
                target = [];
                warning('There is no source vertex exists for %s\n',source_vertex);
            end
        end
        
        
        
        function source = getSource(obj, target_vertex)
            % Returns the name of source vertex of the given target vertex
            %
            % Parameters:
            %  target: the name of the target vertex @type char
            %
            % Return values:
            %  source: the name of the source vertex @type char
            
            % find the rows whose 'target' is the 'target_vertex'
            rows = strcmp({obj.edges.target},target_vertex);
            
            % extract the source vertex using the row indexing
            if any(rows)
                source = {obj.edges(rows).source};
            else
                source = [];
                warning('There is no source vertex exists for %s\n',target_vertex);
            end
        end
    end
        
    
    %% Private methods
    methods (Access=private)
    end
    
end

