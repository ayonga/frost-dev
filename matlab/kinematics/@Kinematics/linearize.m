function obj = linearize(obj, linearize)
    % Sets whether to linearize the function or not
    %
    % Parameters:
    %  linearize: linearize the function if it is true @type
    %  logical
    %
    
    
    % if symbol expressions alreay exist, re-compile them
    if check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol}) ...
            && (linearize ~= obj.options.linearize)
        warning(['The symbolic expressions already exist in Mathematica Kernal.'...,
            'Compile the expressions again with re_load option before use.']);
    end
    obj.options.linearize = linearize;
    
    
end
