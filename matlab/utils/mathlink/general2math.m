function [expr] = general2math(x, varargin)
    % Convert a general expression to a Mathematica expression
    %
    % @author ayonga @date 2016-09-23
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    if isstruct(x)
        expr = struct2assoc(x, varargin{:});
    elseif iscell(x)
        expr = cell2tensor(x, varargin{:});
    elseif isnumeric(x)
        if isscalar(x)
            expr = num2str(x, varargin{:});
        elseif isempty(x)
            expr = '{}';
        else
            expr = mat2math(x, varargin{:});
        end
    elseif ischar(x)
        expr = str2math(x, varargin{:});
    elseif islogical(x)
        if x
            expr = 'True';
        else
            expr = 'False';
        end
    else
        error('Unsupported type: %s', class(x));
    end
end
