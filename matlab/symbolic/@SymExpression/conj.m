function X = conj(Z)
    % Symbolic conjugate.
    %   CONJ(Z) is the conjugate of a symbolic Z.
    
    % Convert inputs to SymExpression
    % Z = SymExpression(Z);
    % construct the operation string
    sstr = ['Conjugate[' Z.s ']'];
    
    % create a new object with the evaluated string
    X = SymExpression(sstr);
end
