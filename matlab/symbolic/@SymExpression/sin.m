function Y = sin(X)
    % Symbolic sine function.
       
    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Sin[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
