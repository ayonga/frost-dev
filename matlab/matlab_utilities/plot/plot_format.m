function [h] = plot_format(h)
if nargin < 1
    h = gcf;
end

width = 6;
height = 6;

set(h, 'PaperUnits', 'inches', ...
    'PaperSize', [width, height], ...
    'PaperPosition', [0, 0, width, height], ...
    'PaperOrientation', 'portrait');

end
