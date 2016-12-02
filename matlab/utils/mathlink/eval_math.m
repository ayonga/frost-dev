function ret = eval_math(expr)
    % A wrapper function that calls the mathlink function to evaluate the
    % expression specified by 'expr'. 
    %
    % Parameters:
    %  expr: a string of Mathematica expression @type char
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
    
    
    
    ret = math(['Check[',expr,',$Failed]']);
    
    assert((~strcmp(ret, '$Failed'))&&(~strcmp(ret, '$Aborted')),...
        'MathLink:evalerr',...
        'The evaluation of Mathematica expression failed.');
    
end
