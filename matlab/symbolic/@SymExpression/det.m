function d = det(A)
    % Symbolic matrix determinant.
    %   DET(A) is the determinant of the symbolic matrix A.
    %
    %   Examples:
    %       det([a b;c d]) is a*d-b*c.

    % Convert inputs to SymExpression
    X = SymExpression(A);
    
    % check if A is a square matrix
    ret = eval_math(['SquareMatrixQ[' X.s ']']);
    

    
    if strcmp('False',ret)
        error(message('symbolic:det:SquareMatrix'));
    end
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Det[' X.s ']']);
    
    % create a new object with the evaluated string
    d = SymExpression(sstr);
end
