function X = conj(Z)
    % Symbolic conjugate.
    %   CONJ(Z) is the conjugate of a symbolic Z.
    
    % Convert inputs to SymExpression
    Z = SymExpression(Z);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Conjugate[' Z.s ']']);
    
    % create a new object with the evaluated string
    X = SymExpression(sstr);
end
