function [h] = plot_save(h, filename)
if nargin < 2
    filename = h;
    h = [];
end
if isempty(h)
    h = gcf;
end

plot_format(h);
print(h, '-dpng', '-r600', filename);
saveas(h, [filename, '.fig']);

end
