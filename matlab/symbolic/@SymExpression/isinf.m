function y = isinf(X)
    % True for infinite elements of symbolic arrays.
    %   ISINF(X) returns an array that contains 1's where the
    %   elements of X are infinite and 0's where they are not.
    %   sym(inf) is infinite; and sums and products
    %   are infinite if at least one term is infinite.
    %   For example, isinf(sym([pi NaN Inf -Inf])) is [0 0 1 1].
    %
    %   For any X, exactly one of ISFINITE(X), ISINF(X), or ISNAN(X)
    %   is 1 for each element.
    %
    %   See also SYM/ISFINITE, SYM/ISNAN.
    
    % Convert inputs to SymExpression
    % X = SymExpression(x);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    ret = eval_math(['Boole/@Map[SameQ, ' X.s ', Infinity]'], 'math2matlab');
    
    y = logical(ret);
end