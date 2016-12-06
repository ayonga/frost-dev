function obj = addVertex(obj, varargin)
% Adds a vertex or a group of vertices to the directed graph
% ''Gamma''.
%
%
% Parameters:
% varargin: variable types of input arguments.
%  S: a structure or structure array defines the name and
%  properties of the vertex. It must have a field name ''Name''
%  to be a valid vertex. If multiple vertices are defined as a
%  single stucture, each field should have the same size. If
%  it is given as a structure array, each array element should
%  have the same properties. Use syntex:
%  @verbatim sys =  addVertex(sys, S) @endverbatim
%  T: a table describes a vertex or vertices to be added. It
%  must have a variable named ''Name'' to be a valid vertex.
%  Use syntex:
%  @verbatim sys =  addVertex(sys, T) @endverbatim
%  NP: a name-value pair type of input argument. The value must
%  a a column cell array, except it is scalar numeric values or
%  row vectors. There must be a 'Name' name-value pair.
%  Use syntex:
%  @verbatim sys =  addVertex(sys, 'Name',{'v1','v2'}', 'Prop1',{p1,p2}',..) @endverbatim

vert_props = obj.VertexProperties;
% if it is a table, we expect that the table has the same set
% of variables as the vertices of the directed graph. Otherwise
% concatenation of the table will not be able to perform correctly
if istable(varargin{1})
    T = varargin{1};
    assert(any(strcmp('Name', T.Properties.VariableNames)),...
        'The table must contain the ''Name'' column.');
    num_vert = size(T,1);
    
    
    
    % get the existing variables in the input table
    varnames  = T.Properties.VariableNames;
    
    
    
    
    % first check if these variables are valid property names
    check_flags = cellfun(@(x)any(strcmp(x, {'Name',vert_props.Name})), T.Properties.VariableNames);
    if ~ all(check_flags)
        error('The table CANNOT contain following columns: %s\n',...
            implode(varnames(~check_flag),', '));
    end
    
    % go through all vertex properties to validate data type
    for i=1:length(vert_props)
        if any(strcmp(vert_props(i).Name, T.Properties.VariableNames))
            % if the table has a certain property, validate the
            % data type
            HybridSystem.validatePropAttribute(T.(vert_props(i).Name),vert_props(i));
        else
            % otherwise, create a column for the missing
            % property with its default value
            default_value = cell(num_vert,1);
            if ~isempty(vert_props(i).DefaultValue)
                % if the default value is nonempty,
                % create a cell array of default values
                for j=1:num_vert
                    default_value{j} = vert_props(i).DefaultValue;
                end
                % if the default value is a numerica row vector,
                % use vertcat
                if isnumeric(vert_props(i).DefaultValue) && ...
                        isrow(vert_props(i).DefaultValue)
                    default_value = vertcat(default_value{:});
                end
            end
            T.(vert_props(i).Name) = default_value;
        end
    end
    
    
    % add the new vertex or vertices to the graph
    obj.Gamma = addnode(obj.Gamma,T);
    
    
    
elseif ischar(varargin{1}) || isstruct(varargin{1})
    
    p = inputParser;
    p.addParameter('Name',{''},@(x)validateattributes(x,{'cell'},{'column'},'iscellstr'));
    
    
    if isstruct(varargin{1})
        % if input is a structure, then use the required field
        % ''Name'' to get the number of vertices to be added
        num_vert = numel(varargin{1}.Name);
    else
        % otherwise, we expect the second argument be the value
        % of the name (or a property)
        num_vert = numel(varargin{2});
    end
    
    for i = 1:length(vert_props)
        default_value = cell(num_vert,1);
        if ~isempty(vert_props(i).DefaultValue)
            % if the default value is nonempty,
            % create a cell array of default values
            for j=1:num_vert
                default_value{j} = vert_props(i).DefaultValue;
            end
            % if the default value is a numerica row vector,
            % use vertcat
            if isnumeric(vert_props(i).DefaultValue) && ...
                    isrow(vert_props(i).DefaultValue)
                default_value = vertcat(default_value{:});
            end
        end
        
        p.addParameter(vert_props(i).Name,default_value,@(x)HybridSystem.validatePropAttribute(x,vert_props(i)));
    end
    
    
    
    parse(p, varargin{:});
    
    if any(strcmp('Name',p.UsingDefaults))
        error('You must specifiy the ''Name'' of the vertex.');
    end
    
    % construct a new struct with correct order of properties
    new_vertex = orderfields(p.Results,['Name',{vert_props.Name}]);
    
    obj.Gamma = addnode(obj.Gamma,struct2table(new_vertex));
    
end



end