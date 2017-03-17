function Y = abs(X)
    % Absolute value.
    %   ABS(X) is the absolute value of the elements of X. When
    %   X is complex, ABS(X) is the complex modulus (magnitude) of
    %   the elements of X.
    
    
    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Abs[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
