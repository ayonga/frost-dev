function Y = diag(A,offset)
    %DIAG   Create or extract symbolic diagonals.
    %   DIAG(V,K), where V is a row or column vector with N components,
    %   returns a square sym matrix of order N+ABS(K) with the
    %   elements of V on the K-th diagonal. K = 0 is the main
    %   diagonal, K > 0 is above the main diagonal and K < 0 is
    %   below the main diagonal.
    %   DIAG(V) simply puts V on the main diagonal.
    %
    %   DIAG(X,K), where X is a sym matrix, returns a column vector
    %   formed from the elements of the K-th diagonal of X.
    %   DIAG(X) is the main diagonal of X.
    %
    %   Examples:
    %
    %      v = [a b c]
    %
    %      Both diag(v) and diag(v,0) return
    %         [ a, 0, 0 ]
    %         [ 0, b, 0 ]
    %         [ 0, 0, c ]
    %
    %      diag(v,-2) returns
    %         [ 0, 0, 0, 0, 0 ]
    %         [ 0, 0, 0, 0, 0 ]
    %         [ a, 0, 0, 0, 0 ]
    %         [ 0, b, 0, 0, 0 ]
    %         [ 0, 0, c, 0, 0 ]
    %
    %      A =
    %         [ a, b, c ]
    %         [ 1, 2, 3 ]
    %         [ x, y, z ]
    %
    %      diag(A) returns
    %         [ a ]
    %         [ 2 ]
    %         [ z ]
    %
    %      diag(A,1) returns
    %         [ b ]
    %         [ 3 ]

    if nargin == 1
        offset = 0;
    end

    
    % Convert inputs to SymExpression
    A = SymExpression(A);
    offset = SymExpression(offset);
    if isvector(A)
        
        
        % construct the operation string
        sstr = ['DiagonalMatrix[Flatten[' A.s '],' offset.s ']'];
        
        % create a new object with the evaluated string
        Y = SymExpression(sstr);
    else
        
        % construct the operation string
        sstr = ['Diagonal[' A.s ',' offset.s ']'];
        
        % create a new object with the evaluated string
        Y = SymExpression(sstr);
    end
end

