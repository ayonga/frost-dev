%> @brief Pretty print a matrix
%> @author Eric Cousineau <eacousineau@gmail.com>, AMBER Lab, under Dr.
%> Aaron Ames
function [str] = array2str(A, varargin)

func = @(x) num2str(x, varargin{:});
raw = arrayfun(func, A, 'UniformOutput', false);
s = size(A);
rows = cell(s(1), 1);
for i = 1:s(1)
    rows{i} = strjoin(raw(i, :), ', ');
end
str = ['[\n\t', strjoin(rows', ';\n\t'), ';\n]'];

end
