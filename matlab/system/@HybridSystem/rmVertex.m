function obj = rmVertex(obj, vertex_name)
% Removes a vertex or a group of vertices from the directed
% graph object ''Gamma''.
%
% @note We only accept char or cellstr type of argument. We do
% not support scalar, vector, or matrix type of arguments that
% the ''rmnode'' function usually supports. This is for
% unexpected behaviors to be occured.
%
% Parameters:
% vertex_name: the vertex name of type cellstr
%
% See also: digraph, rmnode



    assert(iscellstr(vertex_name) || ischar(vertex_name),...
        'Only character vector and cell array of character vector (cellstr) types are supported.');

    % remove node using
    obj.Gamma = rmnode(obj.Gamma, vertex_name);
end