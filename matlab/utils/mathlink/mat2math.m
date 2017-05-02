function expr = mat2math(A, varargin)
    % Converts a 2-D matrix to a string that will be read as a matrix
    % (tensor) in Mathematica
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
    
    s = size(A);
    assert(length(s)==2,'Input matrix must be a 2-D matrix.');
    
    func = @(x) num2mathstr(x, varargin{:});
    raw = arrayfun(func, A, 'UniformOutput', false);
    
    rows = cell(s(1), 1);
    for i = 1:s(1)
        rows{i} = strcat('{',strjoin(raw(i, :), ', '),'}');
    end
    
    %     if s(1) > 1
    expr = ['{',implode(rows',','),'}'];
    %     else
    %         expr = rows{:};
    %     end
    
    
    
    
end
