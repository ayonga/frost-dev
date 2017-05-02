function y = ismatrix(X)
    % True if X is a 2-Dimensional list 
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    ret = eval_math(['Boole@MatrixQ[',X.s,']']);
    
    y = logical(eval(ret));
end