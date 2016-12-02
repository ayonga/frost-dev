function [dmin] = min_abs_nonzero(x, dim)

if nargin < 2 || isempty(dim)
    dim = 1;
end

dmin = min(abs(x(x ~= 0)), [], dim);

end
