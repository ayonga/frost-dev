%> @brief Simple function to plot a comparison between two labelled data
%> sets
%> @author Eric Cousineau <eacousineau@gmail.com>, member of Dr. Aaron
%> Ames's AMBER Lab
function [] = plot_compare(name, t, label1, x1, label2, x2, prefix)

if nargin < 7
    prefix = '[Compare] ';
end

clf();
subplot(2, 1, 1);
hold('on');
lines2 = plot(t, x2, '--', 'LineWidth', 2);
lines1 = plot(t, x1);
lines = [lines1(1); lines2(1)];
legend(lines, {label1, label2});
axis('tight');
title(sprintf('%s%s: %s vs. %s', prefix, name, label1, label2));
ylabel('Compare');
subplot(2, 1, 2);
plot(t, x1 - x2);
axis('tight');
ylabel('Error');

end
