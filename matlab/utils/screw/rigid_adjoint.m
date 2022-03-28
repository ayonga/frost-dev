function adj = rigid_adjoint(g)
    % rigid adjoint matrix from the homonegeous matrix

    R = g(1:3,1:3);%rigid_orientation(g);
    p = g(1:3,4);%rigid_position(g);

    s = skew(p);

    adj = [R, s*R;
        zeros(3), R];
end