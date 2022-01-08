function v = adV(V)
    % the notation is different from the MR book.

    v_bracket = skew(V(1:3));
    w_bracket = skew(V(4:6));
    v = [w_bracket, v_bracket; zeros(3), w_bracket];
end