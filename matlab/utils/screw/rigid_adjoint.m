function adj = rigid_adjoint(g)
    % rigid adjoint matrix from the homonegeous matrix

    R = rigid_orientation(g);
    p = rigid_position(g);

    s = skew(p);

    adj = [R, s*R;
        zeros(3), R];
end