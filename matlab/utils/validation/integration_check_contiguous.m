%> @brief Check integration of contiguous sets of points validating
%> consistency of position and velocity
%> @author Eric Cousineau <eacousineau@gmail.com>
function [x_int] = integration_check_contiguous(ts, x, dx, C, exclude_first, label)

if nargin < 5 || isempty(exclude_first)
    exclude_first = false;
end
if nargin < 6
    label = [];
end

count = length(ts);
sz = size(x);
if sz(1) == count
    dim = 1;
elseif sz(2) == count
    dim = 2;
else
    error('Inconsistent size between ts (%d) and x (%d x %d)', count, sz(1), sz(2));
end

% Preallocate
x_int = nan(size(x));
for i = 1:length(C)
    % Exclude first point since it might be a point at which tau = 0
    if exclude_first
        start = 2;
    else
        start = 1;
    end
    is = C{i}(start:end);
    if isempty(is)
        continue;
    end
    if dim == 1
        x_int(is, :) = integration_check(ts(is), x(is, :), dx(is, :));
    else
        x_int(:, is) = integration_check(ts(is), x(:, is), dx(:, is));
    end
end

if ~isempty(label)
    plot_compare(label, ts, 'Actual', x, 'Integrated', x_int, '[Integration] ');
end

end
