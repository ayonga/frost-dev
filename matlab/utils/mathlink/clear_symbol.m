function status = clear_symbol(var)
    % A wrapper function that clears a symbol specified by the character
    % 'var'
    %
    % @author ayonga @date 2016-11-23
    %
    % Parameters:
    %  var: a string or a cell string of the symbolic variable name @type char
    %
    % Return values:
    %  status: status flag of the operation @type logical
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    clear_sym = @(x) eval_math(['Clear[',x,']']);
    
    if iscell(var)        
        ret = cellfun(clear_sym,var,'UniformOutput',false);        
    elseif ischar(var)
        ret = clear_sym(var);
    else
        warning('The variable name must be a string or cell strings.');
    end
    
    status = all(strcmp('Null',ret));
    
end
