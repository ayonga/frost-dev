%> @brief Find a string's index in a cell array
%> @author Eric Cousineau <eacousineau@gmail.com>
%> @note From amber_classic/core/matlab/util
function [indices] = str_index(needle, haystack)

indices = find(strcmp(needle, haystack));

end
