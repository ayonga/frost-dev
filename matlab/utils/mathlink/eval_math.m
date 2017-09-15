function ret = eval_math(expr, flag, val)
    % A wrapper function that calls the mathlink function to evaluate the
    % expression specified by 'expr'. 
    %
    % @author ayonga @date 2016-11-23
    %
    % Parameters:
    %  expr: a string of Mathematica expression @type char
    %  flag: a char suggests the operation direction @type char
    %  val: value to be assigned 
    %
    % Return values:
    %  ret: the return value of the mathematica evaluation if no error
    %  detected. @type char
    %
    % @author Ayonga Hereid <ayonga27@gmail.com>
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    switch nargin
        case 1
            if strcmp(expr,'quit') || strcmp(expr,'exit')
                math(expr);
                return;
            end
            ret = math(['InputForm[Check[',expr,',$Failed]]']);
            
        case 2
            assert(strcmp(flag, 'math2matlab'), ...
                'The flag must be ''math2matlab'' if it has two arguments');
            
            ret = math('math2matlab', expr);
        case 3
            assert(strcmp(flag, 'matlab2math'), ...
                'The flag must be ''matlab2math'' if it has three arguments');
            
            ret = math('matlab2math', expr, val);
    end
    assert((~strcmp(ret, '$Failed'))&&(~strcmp(ret, '$Aborted')),...
        'MathLink:evalerr',...
        'The evaluation of Mathematica expression failed.');
    
end
