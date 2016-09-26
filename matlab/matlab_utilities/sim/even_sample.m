function [Et,Ex] = even_sample(ts,xs,fs,timeFactor)


if nargin < 4
    timeFactor = 1;
end

dt = 1/fs;

if length(ts) == 1
    %!!!HACK So interp1 won't complain
    ts = [ts, ts + eps];
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
xis = interp1(ts, xs', tis)';

% return the interpolated data
Et = tis;
Ex = xis;

return