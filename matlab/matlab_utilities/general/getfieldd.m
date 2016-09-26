function [value] = getfieldd(obj, field, default)
if nargin < 3
    default = [];
end

value = default;
if ~isempty(obj) && isfield(obj, field)
    value = obj.(field);
end

end