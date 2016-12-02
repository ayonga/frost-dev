%> @brief Simple function to plot bars for error and report
%> tolerance failure
%> @author Eric Cousineau <eacousineau@gmail.com>, member of Dr. Aaron
%> Ames's AMBER Lab
function [err_max, is_err_bad] = check_error(err, labels, err_tol)

if nargin < 2
    labels = [];
end
if nargin < 3
    err_tol = [];
end
if nargin < 4
    prefix = '[Error] ';
end

err_max = max(abs(err));
if ~isempty(err_tol)
    is_err_bad = err_max > err_tol;
else
    is_err_bad = [];
end

% How to put labels?
bar(err_max);

if ~isempty(is_err_bad) && ~isempty(labels)
    fprintf('bad:\n\t%s\n', implode(labels(is_err_bad), ', '));
end

end
