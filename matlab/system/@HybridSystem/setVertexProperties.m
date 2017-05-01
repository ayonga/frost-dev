function obj = setVertexProperties(obj, vertex, varargin)
% Sets the values of vertex properties
%
% Parameters:
%  vertex: the names of the vertices to be configured. It must be a cell string or a
%  character array.
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


% check if the specified vertices exist in the graph
vert = findnode(obj.Gamma, vertex);
if any(find(~vert))
    error('The following vertices are NOT found in the graph: %s\n',...
        implode(vertex(~vert),', '));
end

nNode = numel(vert);

if ~ischar(varargin{1})
    error(['The thrid argument is expected to be a character vector.\n',...
        'Instead it is a %s'], class(varargin{1}));
end

% create a struct from the input ''Name-Value'' pair arguments
% create a struct array from the input
props = struct(varargin{:});
% if not a column array, convert to column array
if ~iscolumn(props)
    props = props';
end

if length(props) == 1 && nNode > 1 
    % if the property value is a scalar, but the number of edges is greater
    % than one, create a structure array to replicate the property value
    for i=2:nNode
        props(i) = props(1);
    end
end

assert(length(props)==nNode,...
    'The number of property values ''%d'' must match the number of nodes ''%d''.\n',...
    length(props), nNode);
propNames = fieldnames(props);

valid_props = obj.VertexProperties;
% first check if these fields are valid property names
check_flags = cellfun(@(x)any(strcmp(x, valid_props.Name)), propNames);
if ~ all(check_flags)
    warning('The following input parameters are not valid properties, they will be not added to the graph: %s\n',...
        implode(propNames(~check_flags),', '));
end
% remove invalid fields
props = rmfield(props, propNames(~check_flags));
    
% get updated field names
propNames = fieldnames(props);

prop_pos = cellfun(@(x)find(strcmp(x, valid_props.Name)), propNames);

% go through all vertex properties to check if the value of a certain
% property is given
for i=1:numel(propNames)
    
    % if a property exists in the input argument, validate its
    % value
    HybridSystem.validatePropAttribute(propNames{i},...
        {props.(propNames{i})},...
        valid_props.Type{prop_pos(i)},valid_props.Attribute{prop_pos(i)});
    
    % if the value is not numeric or a cell, convert it to cell to
    % prevent future concatenation goes wrong
    for j=1:numel(vert)
        k = vert(j);
        if iscell(obj.Gamma.Nodes.(propNames{i})(j))
            obj.Gamma.Nodes.(propNames{i}){k} = props(j).(propNames{i});
        else
            obj.Gamma.Nodes.(propNames{i})(k) = props(j).(propNames{i});
        end
    end
    
end
    



end