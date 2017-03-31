function y = feval(obj)
    % If a SymVariable object has been assigned, the evaluated the
    % assigned expression and return the result; otherwise, return
    % the
    
    % evaluate the operation in Mathematica and return the
    % expression string
    str = eval_math(obj.s);
    
    % return the updated object
    try
        y = eval(str);
    catch
        y = str;
    end
end