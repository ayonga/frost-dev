function obj = addEdge(obj, varargin)
% Adds an edge or a group of edges to the directed graph
% ''Gamma''.
%
% This function is a wrapper function of Matlab ''addedge'' function. It
% provides extra data type validations for each properties of an edge,
% besides it supports more flexible way to assign edge properties. The
% properties will be given as separate input arguments using ''Name-Value''
% pairs, and missing properties will be inserted with the default value of
% the corresponding properties. 
%
% @note To add ''Weights'' to the edge, specifity ''Weights'' properties as
% other properties. See detailed explanation of the input arguments.
%
% See also: addedge
%
% Parameters:
% varargin: variable types of input arguments.
%  T: a table describes an edge or edges to be added. It
%  must have a variable named ''EndNodes'' to be a valid edge. Variables that
%  do not match any of the edge properties will be ignored. Missing
%  edge properties will be added with its default values.
%  Use syntex
%  @verbatim sys =  addVertex(sys, T) @endverbatim
%  @type table
%  s,t: the name pairs of the source vertics and target vertices to be added. 
%  They must be a cell string or a character array.
%  Use syntex
%  @verbatim sys =  addVertex(sys, s, t) @endverbatim
%  @type cellstr
%  PropName: a character vector specifiy the name of an edge property 
%  for the added edges. It must be given as a ''Name''-''Value'' pairs.
%  @type char
%  PropValue: the values of the edge properties specified by the
%  ''PropName''. It must be scalar or a cell array with the the same length
%  of the number of the vertices to be added. If it is a scalar, all edges
%  will be assign this scalar value.
%  Use syntex
%  @verbatim sys =  addVertex(sys, s, t, PropName,PropValue,...) @endverbatim
%  @type cell
% 
% @note A struct can be used to replace the (PropName, PropValue) inputs.
% To be valid input, the structure must have fields with the same name as
% vertex properties. For mutilple nodes, use the array of structures instead of
% the structure of arrays. Invalid fields in the structure will be ignored,
% and missing properties will be added with their default values.



valid_props = obj.EdgeProperties;

if istable(varargin{1})
    % if the first argmument is a NodeTable
    T = varargin{1};
    nEdge = size(T,1);
    
    % first check if these variables are valid property names
    check_flags = cellfun(@(x)any(strcmp(x, ['EndNodes',valid_props.Name])), T.Properties.VariableNames);
    if ~ all(check_flags)
        warning('The following variables are not valid properties, they will be not added to the graph: %s\n',...
            implode(T.Properties.VariableNames(~check_flags),', '));
    end
    
    for i = find(~check_flags)
        % remove invalid variables
        T.(T.Properties.VariableNames{i}) = [];
    end
    
    % go through all edge properties to validate data type. If a property
    % is not exist in the table, insert its default value to the table
    for i=1:numel(valid_props.Name)
        if any(strcmp(valid_props.Name{i}, T.Properties.VariableNames))
            % if the table has a certain property, validate the
            % data type
            HybridSystem.validatePropAttribute(valid_props.Name{i},...
                T.(valid_props.Name{i}),...
                valid_props.Type{i},valid_props.Attribute{i});
        else
            % otherwise, insert a variable to the table for the missing
            % property with its default value
            default_value = cell(nEdge,1);
            if ~isempty(valid_props.DefaultValue{i})
                % if the default value is nonempty,
                % create a cell array of default values
                for j=1:nEdge
                    default_value{j} = valid_props.DefaultValue{i};
                end
                % if the default value is a numerica row vector,
                % use vertcat
                if isnumeric(valid_props.DefaultValue{i}) && ...
                        isrow(valid_props.DefaultValue{i})
                    default_value = vertcat(default_value{:});
                end
            end
            T.(valid_props.Name{i}) = default_value;
        end
    end
    
    % add vertex if it is not already in the graph
    s = T.EndNodes(:,1);
    t = T.EndNodes(:,2);
    
    num_node_gamma = numnodes(obj.Gamma);
    if isnumeric(s) && isnumeric(t)
        max_node_num = max([s',t']);
        if max_node_num > num_node_gamma
            obj = addVertex(obj, max_node_num - num_node_gamma);
        end
    elseif iscellstr(s) && iscellstr(t)
        node_in_table = [s',t'];
        inds = findnode(obj.Gamma, node_in_table);
        if any(~inds)
            obj = addVertex(obj, node_in_table(~inds));
        end
    end
    
    % add the new edge or vertices to the graph
    obj.Gamma = addedge(obj.Gamma,T);

    
elseif (ischar(varargin{1}) || iscellstr(varargin{1})) && ...
        (ischar(varargin{2}) || iscellstr(varargin{2}))
    % if the first two arguments are the vertex name character or a cell
    % string of vertices' name
    
    s = varargin{1};
    t = varargin{2};
    if ~iscellstr(s)
        s = {s};
    end
    if ~iscellstr(t)
        t = {t};
    end
    assert(numel(s) == numel(t),...
        'The number of source vertices ''%d'' and the number of target vertices ''%d'' must be equal.\n',...
        numel(s), numel(t));
    % the number of nodes to be added
    nEdge = numel(s);
    
    % create a struct from the input ''Name-Value'' pair arguments
    if nargin > 3
        % create a struct array from the input
        props = struct(varargin{3:end});
        % if not a column array, convert to column array
        if ~iscolumn(props)
            props = props';
        end
        assert(length(props)==nEdge,...
            'The number of property values ''%d'' must match the number of edges ''%d''.\n',...
            length(props), nEdge);
        propNames = fieldnames(props);
        % first check if these fields are valid property names
        check_flags = cellfun(@(x)any(strcmp(x, valid_props.Name)), propNames);
        if ~ all(check_flags)
            warning('The following input parameters are not valid properties, they will be not added to the graph: %s\n',...
                implode(propNames(~check_flags),', '));
        end
        % remove invalid fields
        props = rmfield(props, propNames(~check_flags));
    else
        props = struct([]);
    end
    
    
    % go through all edge properties to check if the value of a certain
    % property is given
    for i=1:numel(valid_props.Name)
        if isfield(props, valid_props.Name{i})
            % if a property exists in the input argument, validate its
            % value
            HybridSystem.validatePropAttribute(valid_props.Name{i},...
                {props.(valid_props.Name{i})},...
                valid_props.Type{i},valid_props.Attribute{i});
            % if the value is not numeric or a cell, convert it to cell to
            % prevent future concatenation goes wrong
            for j=1:nEdge
                if ~isnumeric(props(j).(valid_props.Name{i})) &&...
                    ~ iscell(props(j).(valid_props.Name{i}))
                    props(j).(valid_props.Name{i}) = {props(j).(valid_props.Name{i})};
                end
            end
        else
            % otherwise, insert a field to the struct for the missing
            % property with its default value
            for j=1:nEdge
                props(j).(valid_props.Name{i}) = valid_props.DefaultValue{i};
            end
        end
        
    end
    
    % add vertex if it is not already in the graph
    num_node_gamma = numnodes(obj.Gamma);
    if isnumeric(s) && isnumeric(t)
        max_node_num = max([s',t']);
        if max_node_num > num_node_gamma
            obj = addVertex(obj, max_node_num - num_node_gamma);
        end
    elseif iscellstr(s) && iscellstr(t)
        node_in_table = [s',t'];
        inds = findnode(obj.Gamma, node_in_table);
        if any(~inds)
            obj = addVertex(obj, node_in_table(~inds));
        end
    end
    
    % add ''EndNodes'' field to the ''props'' structure
    for i = 1:nEdge
        props(i).EndNodes = [s(i), t(i)];
    end
    
    % construct a new struct with correct order of properties
    new_edge = orderfields(props,['EndNodes',valid_props.Name]);
    
    obj.Gamma = addedge(obj.Gamma,struct2table(new_edge));
else
    error(['The second argument is expected to be a table or a cell string/charaecter vector.',...
        'Instead it is a %s'],class(varargin{1}));
end



end