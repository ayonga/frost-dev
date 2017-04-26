function Y = sech(X)
    %  Symbolic hyperbolic secant.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Sech[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
