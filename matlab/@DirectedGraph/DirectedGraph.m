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
        
        
        
        % A table describes the edges in the directed graph
        %
        % @type table
        edges
        
        % A table describes the vertices (nodes) in the directed graph
        %
        % @type table
        vertices
        
        
        % A structure shows different modeling options
        %
        % @type struct
        graphOptions = struct(...
            'isPeriodic', true);
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = DirectedGraph(varargin)
            % the basic class constructor function
            
            
            
            p = inputParser;
            addRequired(p, 'vertices',@iscellstr);
            addOptional(p, 'edges', [], @iscell);
            addParameter(p, 'options',obj.options);
            
            parse(p,varargin{:});
            
            
            inputs = p.Results;
            
            obj.graphOptions = struct_overlay(obj.options, inputs.options);
            
            obj.vertices = cell2table(transpose(inputs.vertices));
            num_vertices = numel(inputs.vertices);
            if isempty(inputs.edges)
                source_indices = cumsum(ones(num_vertices,1));
                target_indices = source_indices(1:end-1) + 1;
                if obj.graphOptions.isPeriodic
                    target_indices(num_vertices) = 1;
                end
            else
                source_indices = inputs.edges{1};
                target_indices = inputs.edges{2};
                if obj.graphOptions.isPeriodic
                    assert(numel(source_indices) == numel(target_indices),...
                        'The periodic graph requires the number of target and source vertices are equal.');
                    assert(source_indices(1) == target_indices(end),...
                        ['The periodic graph requires the first vertex in the source vertices list',... 
                        'is the same as the last vertex of in the target vertices list.\n']);
                end
            end
            
            Source = transpose(inputs.vertices(source_indices));
            Target = transpose(inputs.vertices(target_indices));
            
            obj.edges = table(Source, Target);
            
        end
        
        
        function target = getTarget(obj, source)
            % Returns the name of target vertex of the given source vertex
            %
            % Parameters:
            %  source: the name of the source vertex @type string
            %
            % Return values:
            %  target: the name of the target vertex @type string
            
            % find the rows whose 'Source' is source
            rows = strcmp(obj.edges.Source,source);
            
            % extrc
            target = obj.edges.Target{rows};
        end
        
        
        function source = getSource(obj, target)
            % Returns the name of source vertex of the given target vertex
            %
            % Parameters:
            %  target: the name of the target vertex @type string
            %
            % Return values:
            %  source: the name of the source vertex @type string
            
            % find the rows whose 'Target' is target
            rows = strcmp(obj.edges.Target,target);
            
            % extrc
            source = obj.edges.Source{rows};
        end
    end
        
    
    %% Private methods
    methods (Access=private)
    end
    
end

