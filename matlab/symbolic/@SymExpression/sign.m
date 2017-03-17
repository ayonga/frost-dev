function Y = sign(X)
    % Symbolic sign function.
    %   For each element of X, sign(X) returns 1 if the element
    %   is greater than zero, 0 if it equals zero and -1 if it is
    %   less than zero. For the nonzero elements of complex X,
    %   sign(X) = X/ABS(X).
    %
    %   See also ABS, SYM/ABS


    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Sign[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
