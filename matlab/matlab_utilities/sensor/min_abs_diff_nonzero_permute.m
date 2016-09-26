function [dmin] = min_abs_diff_nonzero_permute(x)

[X1, X2] = meshgrid(x);
x_diff = X1 - X2;

dmin = min(abs(x_diff(x_diff ~= 0)));

end
