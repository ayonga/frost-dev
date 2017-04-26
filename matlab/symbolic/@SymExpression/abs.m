function Y = abs(X)
    % Absolute value.
    %   ABS(X) is the absolute value of the elements of X. When
    %   X is complex, ABS(X) is the complex modulus (magnitude) of
    %   the elements of X.
    
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Abs[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
