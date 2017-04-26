function J = jacobian(A, x)
    % Jacobian of the symbolic expression
    
    assert(isvector(A), 'The symbolic expression must be a vector.');
    assert(isa(x,'SymVariable'), 'The second argument must a list of symbolic variable.');
    assert(isvector(x), 'The second argument must be a vector.');
    % Convert inputs to SymExpression
    
    
    % construct the operation string
    sstr = ['D[Flatten@{' A.s '},{Flatten@{' x.s '},1}]'];
    
    % create a new object with the evaluated string
    J = SymExpression(sstr);

end