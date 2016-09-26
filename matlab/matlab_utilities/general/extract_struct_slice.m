function [out] = extract_struct_slice(in, index, dim)
if nargin < 3
    dim = 1;
end

assert(any(dim == [1, 2]));

out = in;
fields = fieldnames(in);
for i = 1:length(fields)
    field = fields{i};
    x = in.(field);
    if dim == 1
        y = x(index, :);
    elseif dim == 2
        y = x(:, index);
    end
    out.(field) = y;
end

end
