function Z = atan(Y,X)
    % Symbolic inverse tangent.
    %       With two arguments, ATAN(Y,X) is the symbolic form of ATAN2(Y,X).

    
    
    if nargin == 1
        % Convert inputs to SymExpression
        X = SymExpression(X);
        % evaluate the operation in Mathematica and return the
        % expression string
        sstr = eval_math(['ArcTan[' X.s ']']);
        
        % create a new object with the evaluated string
        Z = SymExpression(sstr);
    else
        % Convert inputs to SymExpression
        X = SymExpression(X);
        Y = SymExpression(Y);
        % evaluate the operation in Mathematica and return the
        % expression string
        sstr = eval_math(['ArcTan[' X.s ',' Y.s ']']);
        
        % create a new object with the evaluated string
        Z = SymExpression(sstr);
    end
end
