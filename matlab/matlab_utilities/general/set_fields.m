function [s] = set_fields(s, value)
if nargin < 2
    value = nan;
end

assert(isstruct(s));
fields = fieldnames(s);
for i = 1:length(fields)
    field = fields{i};
    x = s.(field);
    if iscell(x) || isnumeric(x)
        x(:) = value;
        s.(field) = x;
    end
end

end
