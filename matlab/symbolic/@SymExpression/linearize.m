function B = linearize(A, v)
    % Linearize of the symbolic expression A w.r.t. the symbolic vector
    % variable v
    %
    % B = ((dA/dv)|v=0)*v
    
    assert(isvector(A), 'The symbolic expression must be a vector.');
    assert(isa(v,'SymVariable'), 'The second argument must a list of symbolic variable.');
    assert(isvector(v), 'The second argument must be a vector.');
    
    A = SymExpression(A);
    
    % compute the Jacobian first
    J = jacobian(A,v);
    J0 = subs(J,v,zeros(size(v)));
    
    B = J0*v;
    

end