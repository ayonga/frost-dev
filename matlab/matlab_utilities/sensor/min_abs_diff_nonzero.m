function [dmin] = min_abs_diff_nonzero(x, dim)

if nargin < 2 || isempty(dim)
    dim = 1;
end

x_diff = diff(x, [], dim);

dmin = min(abs(x_diff(x_diff ~= 0)), [], dim);

end
