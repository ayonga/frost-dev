%> @brief Convert a general cell array matrix to a string
%> @author Eric Cousineau <eacousineau@gmail.com>, AMBER Lab, under Dr.
%> Aaron Ames
%> @param X cell array
%> @param varargin Arguments to propagate to general2str()
function [str] = cell2str(X, varargin)
s = size(X);
func = @(x) general2str(x, varargin{:});
raw = cellfun(func, X, 'UniformOutput', false);
rows = cell(s(1), 1);
for i = 1:s(1)
    rows{i} = implode(raw(i, :), ', ');
end
str = ['{\n', indent(strjoin(rows', ';\n'), '\t'), ';\n}'];
end
