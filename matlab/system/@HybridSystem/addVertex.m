function obj = addVertex(obj, varargin)
% Adds a vertex or a group of vertices to the directed graph
% ''Gamma''.
%
% This function is a wrapper function of Matlab ''addnode'' function. It
% provides extra data type validations for each properties of a vertex,
% besides it supports more flexible way to assign properties. The
% properties will be given as separate input arguments using ''Name-Value''
% pairs, and missing properties will be inserted with the default value of
% the corresponding properties. 
%
%
% See also: addnode
%
% Parameters:
%  T: a table describes a vertex or vertices to be added. It
%  must have a variable named ''Name'' to be a valid vertex. Variables that
%  do not match any of the vertex properties will be ignored. Missing
%  vertex properties will be added with its default values.
%  Use syntex
%  @verbatim sys =  addVertex(sys, T) @endverbatim
%  @type table
%  Vert: the names of the vertices to be added. It must be a cell string or a
%  character array.
%  Use syntex
%  @verbatim sys =  addVertex(sys, Vert) @endverbatim
%  @type cellstr
%  PropName: a character vector specifiy the name of a vertex property 
%  for the added vertices. It must be given as a ''Name''-''Value'' pairs.
%  PropValue: the values of the vertex properties specified by the
%  ''PropName''. It must be scalar or a cell array with the the same length
%  of the number of the vertices to be added. If it is a scalar, all edges
%  will be assign this scalar value.
%  Use syntex
%  @verbatim sys =  addVertex(sys, Vert, PropName,PropValue,...) @endverbatim
%  @type char
%
% @note A struct can be used to replace the (PropName, PropValue) inputs.
% To be valid input, the structure must have fields with the same name as
% vertex properties. For mutilple nodes, use the array of structures instead of
% the structure of arrays. Invalid fields in the structure will be ignored,
% and missing properties will be added with their default values.

valid_props = obj.VertexProperties;

if istable(varargin{1})
    % if the first argmument is a NodeTable
    T = varargin{1};
    nNode = size(T,1);
    
    % first check if these variables are valid property names
    check_flags = cellfun(@(x)any(strcmp(x, ['Name',valid_props.Name])), T.Properties.VariableNames);
    if ~ all(check_flags)
        warning('The following variables are not valid properties, they will be not added to the graph: %s\n',...
            implode(T.Properties.VariableNames(~check_flags),', '));
    end
    
    for i = find(~check_flags)
        % remove invalid variables
        T.(T.Properties.VariableNames{i}) = [];
    end
    
    % go through all vertex properties to validate data type. If a property
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
            default_value = cell(nNode,1);
            if ~isempty(valid_props.DefaultValue{i})
                % if the default value is nonempty,
                % create a cell array of default values
                for j=1:nNode
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
    
    
    % add the new vertex or vertices to the graph
    obj.Gamma = addnode(obj.Gamma,T);

elseif isnumeric(varargin{1}) && isscalar(varargin{1})
    numNodes = varargin{1};
    if ~isreal(numNodes) || fix(numNodes) ~= numNodes || numNodes < 0
        error(message('MATLAB:graphfun:addnode:InvalidNrNodes'));
    end
    num_node_gamma = numnodes(obj.Gamma);
    
    newnodes = cellstr([repmat('Node', numNodes, 1) ...
            num2str(num_node_gamma+(1:numNodes)', '%-d')]);
    obj = addVertex(obj, newnodes, varargin{2:end});
    
elseif ischar(varargin{1}) || iscellstr(varargin{1})
    % if the first argument is the vertex name character or a cell string
    % of vertices' name
    
    names = varargin{1};
    if ~iscellstr(names)
        names = {names};
    end
    % the number of nodes to be added
    nNode = numel(names);
    
    % create a struct from the input ''Name-Value'' pair arguments
    if nargin > 2
        % create a struct array from the input
        props = struct(varargin{2:end});
        % if not a column array, convert to column array
        if ~iscolumn(props)
            props = props';
        end
        assert(length(props)==nNode,...
            'The number of property values ''%d'' must match the number of nodes ''%d''.\n',...
            length(props), nNode);
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
    
    
    % go through all vertex properties to check if the value of a certain
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
            for j=1:nNode
                if ~isnumeric(props(j).(valid_props.Name{i})) ||...
                    ~ iscell(props(j).(valid_props.Name{i}))
                    props(j).(valid_props.Name{i}) = {props(j).(valid_props.Name{i})};
                end
            end
        else
            % otherwise, insert a field to the struct for the missing
            % property with its default value
            for j=1:nNode
                props(j).(valid_props.Name{i}) = valid_props.DefaultValue{i};
            end
        end
        
    end
    
    % add ''Name'' field to the ''props'' structure
    for i = 1:nNode
        props(i).Name = names(i);
    end
    
    % construct a new struct with correct order of properties
    new_vertex = orderfields(props,['Name',valid_props.Name]);
    
    obj.Gamma = addnode(obj.Gamma,struct2table(new_vertex));
else
    error(['The second argument is expected to be a table or a cell string/charaecter vector.',...
        'Instead it is a %s'],class(varargin{1}));
    
end



end