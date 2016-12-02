%> @brief Find a string's index in a cell array
%> @author Eric Cousineau <eacousineau@gmail.com>
%> @note From amber_classic/core/matlab/util
function [indices] = str_indices(needles, haystack, varargin)

indices = cellfun(@(needle) find(strcmp(needle, haystack), 1), needles, varargin{:});

end
