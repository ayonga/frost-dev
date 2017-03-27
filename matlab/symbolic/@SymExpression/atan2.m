function Z = atan2(Y,X)
    %  Symbolic four quadrant inverse tangent

    % Convert inputs to SymExpression
    X = SymExpression(X);
    Y = SymExpression(Y);
    % construct the operation string
    sstr = ['ArcTan[' X.s ',' Y.s ']'];
    
    % create a new object with the evaluated string
    Z = SymExpression(sstr);

end
