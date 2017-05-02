function status = check_var_exist(var)
    % A wrapper function that checks if a variable has been assigned to a
    % value in Mathematica
    %
    % @author ayonga @date 2016-11-23
    %
    % Parameters:
    %  var: a string or a cell string of the symbolic variable name @type char
    %
    % Return values:
    %  status: returns true if the variable exists and has been assigned a
    %  value, returns false otherwise. @type logical
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
    
    valueQ = @(x) eval_math(['ValueQ[',x,']']);
    
    if iscell(var)        
        ret = cellfun(valueQ,var,'UniformOutput',false);        
    elseif ischar(var)
        ret = valueQ(var);
    else
        warning('The variable name must be a string or cell strings.');
    end
    
    status = all(strcmp('True',ret));
    
end
