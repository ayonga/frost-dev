function [h] = hline(y, linetype)

if nargin < 2
    linetype={'r:'};
end

xlims = get(gca,'xlim');
count = length(y);
xs = repmat(xlims, count, 1);
ys = repmat(y(:), 1, 2);
h = plot(xs', ys', linetype{:});

end
