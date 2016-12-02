%> @brief Convert a general expression to a string
%> @author Eric Cousineau <eacousineau@gmail.com>, AMBER Lab, under Dr.
%> Aaron Ames
%> @param x Expression
%> @param varargin Arguments to propagate to num2str()
function [str] = general2str(x, varargin)
if isstruct(x)
    str = struct2str(x, varargin{:});
elseif iscell(x)
    str = cell2str(x, varargin{:});
elseif isnumeric(x)
    if isscalar(x)
        str = num2str(x, varargin{:});
    elseif isempty(x)
        str = '[]';
    else
        str = array2str(x, varargin{:});
    end
elseif ischar(x)
    %> @todo Escape the string!
    str = ['''', x, ''''];
elseif islogical(x)
    if x
        str = 'true';
    else
        str = 'false';
    end
else
    error('Unsupported type: %s', class(x));
end
end
