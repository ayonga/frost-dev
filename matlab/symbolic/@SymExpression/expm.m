function Y = expm(X)
    %  Symbolic matrix exponential.
    %   EXPM(A) is the matrix exponential of the symbolic matrix A.
    %
    %   Examples:
    %      syms t
    %      A = [0 1; -1 0]
    %      expm(t*A)
    


    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['MatrixExp[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
