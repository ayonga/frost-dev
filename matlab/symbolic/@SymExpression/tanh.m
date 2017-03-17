function Y = tanh(X)
    % Symbolic hyperbolic tangent.
    
    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Tanh[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
