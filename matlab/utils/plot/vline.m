function [h] = vline(x, varargin)

ylims = get(gca,'ylim');
count = length(x);
ys = repmat(ylims, count, 1);
xs = repmat(x(:), 1, 2);
h = plot(xs', ys', varargin{:});

end
