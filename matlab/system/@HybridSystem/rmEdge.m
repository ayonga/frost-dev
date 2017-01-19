function obj = rmEdge(obj, s, t)
% Removes a edge or a group of edges from the directed
% graph object ''Gamma''.
%
% @note We only accept char or cellstr type of argument. We do
% not support scalar, vector, or matrix type of arguments that
% the ''rmnode'' function usually supports. This is for
% unexpected behaviors to be occured.
%
% Parameters:
% s: the source vertices @type cellstr
% t: the target vertices @type cellstr
%
% See also: digraph, rmnode



    assert(iscellstr(s) || ischar(s) || isnumeric(s),...
        'Only character vector or numeric data types are supported.');
    assert(iscellstr(t) || ischar(t) || isnumeric(t),...
        'Only character vector or numeric data types are supported.');

    % remove node using
    obj.Gamma = rmedge(obj.Gamma, s, t);
end