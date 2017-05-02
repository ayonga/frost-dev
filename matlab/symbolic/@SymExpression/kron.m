function K = kron(X,Y)
    % Symbolic Kronecker tensor product.
    %   KRON(X,Y) is the Kronecker tensor product of X and Y.
    %   The result is a large matrix formed by taking all possible
    %   products between the elements of X and those of Y. For
    %   example, if X is 2 by 3, then KRON(X,Y) is
    %
    %      [ X(1,1)*Y  X(1,2)*Y  X(1,3)*Y
    %        X(2,1)*Y  X(2,2)*Y  X(2,3)*Y ]
    %
    %   X and Y must be SYM objects.
    %
    
    
    % Convert inputs to SymExpression
    X = SymExpression(X);
    Y = SymExpression(Y);
    
    % construct the operation string
    sstr = ['KroneckerProduct[' X.s ',' Y.s ']'];
    % create a new object with the evaluated string
    K = SymExpression(sstr);
end
