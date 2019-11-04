function [Et,Ex] = even_sample(ts,xs,fs,timeFactor)


if nargin < 4
    timeFactor = 1;
end

dt = 1/fs;

if length(ts) == 1
    %!!!HACK So interp1 won't complain
    ts = [ts, ts + 1e10*eps];
    xs = [xs, xs];
end
% Stretch by time factor so things stay at the desired frameIndex rate
% with some smoothness from interpolation
ts = ts * timeFactor;
% Interpolate
tis = ts(1):dt:ts(end);
% Cheap, to make sure endpoint is included - better calc?
if tis(end) ~= ts(end)
    tis(end + 1) = ts(end);
end

[tu, idx] = unique(ts);
xu = xs(:, idx);

% xis = interp1(ts, xs', tis)';
xis = interp1(tu, xu', tis)';


% return the interpolated data
Et = tis;
Ex = xis;

return