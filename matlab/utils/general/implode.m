%> @brief Stick together a cell array of strings using glue
%> @author Eric Cousineau <eacousineau@gmail.com>, AMBER Lab, under Dr.
%> Aaron Ames
%> @example
%> >> implode({'a', 'b', 'c'}, '.')
%> a.b.c
function [res] = implode(pieces, glue)

temp = repmat({glue}, length(pieces) * 2 - 1, 1);
temp(1:2:end) = pieces;
res = [temp{:}];

end
