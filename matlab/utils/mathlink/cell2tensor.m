function [expr] = cell2tensor(X, varargin)
    % Convert a cell array to a Mathematica tensor
    %
    % @author ayonga @date 2016-11-23
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    s = size(X);
    func = @(x) general2math(x, varargin{:});
    raw = cellfun(func, X, 'UniformOutput', false);
    rows = cell(s(1), 1);
    for i = 1:s(1)
        rows{i} = ['{',implode(raw(i, :), ', '),'}'];
    end
    if s(1) > 1
        expr = ['{', implode(rows',', '), '}'];
    else
        expr = rows{:};
    end
end
