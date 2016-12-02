%> @brief Use simple numerical integration to verify validate measured
%> velocities against positions
%> @author Eric Cousineau <eacousineau@gmail.com>
function [x_int, x_err] = integration_check(ts, x, dx, label)

if nargin < 4
    label = [];
end

assert(isvector(ts), 'Time (ts) should be a vector');
count = length(ts);
sz = size(x);

if sz(1) == count
    x0_int = repmat(x(1, :), count, 1);
elseif sz(2) == count
    x0_int = repmat(x(:, 1), 1, count);
else
    error('Inconsistent size between ts (%d) and x (%d x %d)', count, sz(1), sz(2));
end

if count == 1
    x_int = x0_int;
else
    if sz(1) == count
        x_int = x0_int + cumtrapz(ts(:), dx);
    else
        x_int = x0_int + cumtrapz(ts(:), dx')';
    end
end

x_err = x - x_int;

if ~isempty(label)
    plot_compare(label, ts, 'Actual', x, 'Integrated', x_int, '[Integration] ');
end

end
