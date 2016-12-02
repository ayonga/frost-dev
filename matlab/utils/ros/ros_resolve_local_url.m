%> @brief ros_resolve_local_url Resolve a local url using file:// or
%> package:// 'protocol'
%> @param url Url to resolve
%> @note If the pattern is 'package://${package}/${rel}', it will return
%> the path `fullfile(rospack_find(package), rel)`
function [path] = ros_resolve_local_url(url)

prefix = 'file://';
is = strfind(url, prefix);
if ~isempty(is) && is(1) == 1
    path = url(length(prefix) + 1:end);
else
    prefix = 'package://';
    is = strfind(url, prefix);
    if ~isempty(is) && is(1) == 1
        cur = url(length(prefix) + 1:end);
        is = strfind(cur, '/');
        if isempty(is)
            package = cur;
            rel = '';
        else
            package = cur(1:(is(1) - 1));
            rel = cur(is(1) + 1:end);
        end
        path = fullfile(rospack_find(package), rel);
    else
        path = url;
    end
end

end
