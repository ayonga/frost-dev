function J = hessian(A, x)
    % Jacobian of the symbolic expression
    
    assert(isvectorform(A), 'The symbolic expression must be a vector.');
    assert(isa(x,'SymVariable'), 'The second argument must a list of symbolic variable.');
    
    % Convert inputs to SymExpression
    A = SymExpression(A);
    x = tovector(x);
    
    % construct the operation string
    sstr = ['D[' A.s ',{' x.s ',2}]'];
    
    % create a new object with the evaluated string
    J = SymExpression(sstr);

end