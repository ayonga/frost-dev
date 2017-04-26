function d = det(A)
    % Symbolic matrix determinant.
    %   DET(A) is the determinant of the symbolic matrix A.
    %
    %   Examples:
    %       det([a b;c d]) is a*d-b*c.

    % Convert inputs to SymExpression
    % A = SymExpression(A);
    
    % check if A is a square matrix
    ret = eval_math(['SquareMatrixQ[' A.s ']']);
    

    
    if strcmp('False',ret)
        error(message('symbolic:det:SquareMatrix'));
    end
    
    % construct the operation string
    sstr = ['Det[' A.s ']'];
    
    % create a new object with the evaluated string
    d = SymExpression(sstr);
end
