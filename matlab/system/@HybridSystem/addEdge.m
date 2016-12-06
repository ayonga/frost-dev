function obj = addEdge(obj, varargin)
% Adds an edge or a group of edges to the directed graph
% ''Gamma''.
%
%
% Parameters:
% varargin: variable types of input arguments.
%  S: a structure or structure array defines the source, target and
%  properties of the edge. It must have a field name ''Source'' and 
%  a field name ''Target'' to be a valid edge. If multiple 
%  edges are defined as a single stucture, each field should 
%  have the same size. Use syntex:
%  @verbatim sys =  addEdge(sys, S) @endverbatim
%  T: a table describes an edge or edges to be added. It
%  must have a variable named ''EndNodes'' to be a valid edge.
%  Use syntex:
%  @verbatim sys =  addEdge(sys, T) @endverbatim
%  NP: a name-value pair type of input argument. The value must
%  a a column cell array, exept it is scalar numeric values or
%  row vectors. There must be a 'Source' and a 'Target' name-value pair.
%  Use syntex:
%  @verbatim sys =  addEdge(sys, 'Source',{'v1','v2'}', 'Target', {'v1','v2'}','Prop1',{p1,p2}',..) @endverbatim

edge_props = obj.EdgeProperties;
% if it is a table, we expect that the table has the same set of variables
% as the edges of the directed graph. Otherwise concatenation of the table
% will not be able to perform correctly
if istable(varargin{1})
    T = varargin{1};
    assert(any(strcmp('EndNodes', T.Properties.VariableNames)),...
        'The table must contain the ''EndNodes'' column.');
    num_edge = size(T,1);
    
    
    
    % get the existing variables in the input table
    varnames  = T.Properties.VariableNames;
    
    
    
    
    % first check if these variables are valid property names
    check_flags = cellfun(@(x)any(strcmp(x, {'EndNodes',edge_props.Name})), T.Properties.VariableNames);
    if ~ all(check_flags)
        error('The table CANNOT contain following columns: %s\n',...
            implode(varnames(~check_flag),', '));
    end
    
    % go through all edge properties to validate data type
    for i=1:length(edge_props)
        if any(strcmp(edge_props(i).Name, T.Properties.VariableNames))
            % if the table has a certain property, validate the
            % data type
            HybridSystem.validatePropAttribute(T.(edge_props(i).Name),edge_props(i));
        else
            % otherwise, create a column for the missing
            % property with its default value
            default_value = cell(num_edge,1);
            if ~isempty(edge_props(i).DefaultValue)
                % if the default value is nonempty,
                % create a cell array of default values
                for j=1:num_edge
                    default_value{j} = edge_props(i).DefaultValue;
                end
                % if the default value is a numerica row vector,
                % use vertcat
                if isnumeric(edge_props(i).DefaultValue) && ...
                        isrow(edge_props(i).DefaultValue)
                    default_value = vertcat(default_value{:});
                end
            end
            T.(edge_props(i).Name) = default_value;
        end
    end
    
    
    % add the new edge or edges to the graph
    obj.Gamma = addedge(obj.Gamma,T);
    
    
    
elseif ischar(varargin{1}) || isstruct(varargin{1})
    
    p = inputParser;
    p.addParameter('Source',{''},@(x)validateattributes(x,{'cell'},{'column'},'iscellstr'));
    p.addParameter('Target',{''},@(x)validateattributes(x,{'cell'},{'column'},'iscellstr'));
    
    if isstruct(varargin{1})
        % if input is a structure, then use the required field
        % ''Name'' to get the number of edges to be added
        num_edge = numel(varargin{1}.Source);
    else
        % otherwise, we expect the second argument be the value
        % of the name (or a property)
        num_edge = numel(varargin{2});
    end
    
    for i = 1:length(edge_props)
        default_value = cell(num_edge,1);
        if ~isempty(edge_props(i).DefaultValue)
            % if the default value is nonempty,
            % create a cell array of default values
            for j=1:num_edge
                default_value{j} = edge_props(i).DefaultValue;
            end
            % if the default value is a numerica row vector,
            % use vertcat
            if isnumeric(edge_props(i).DefaultValue) && ...
                    isrow(edge_props(i).DefaultValue)
                default_value = vertcat(default_value{:});
            end
        end
        
        p.addParameter(edge_props(i).Name,default_value,@(x)HybridSystem.validatePropAttribute(x,edge_props(i)));
    end
    
    
    
    parse(p, varargin{:});
    
    if any(strcmp('Source',p.UsingDefaults))
        error('You must specifiy the ''Source'' of the edge.');
    end
    if any(strcmp('Target',p.UsingDefaults))
        error('You must specifiy the ''Target'' of the edge.');
    end
    
    
    s = findnode(obj.Gamma, p.Results.Source);
    t = findnode(obj.Gamma, p.Results.Target);
    
    edge_struct = rmfield(p.Results,{'Source','Target'});
    edge_struct.EndNodes = [s,t];
    % construct a new struct with correct order of properties
    new_edge = orderfields(edge_struct,['EndNodes',{edge_props.Name}]);
    
    obj.Gamma = addedge(obj.Gamma,struct2table(new_edge));
    
end



end