function p = rigid_position(g)
    % extract the rigid position from the homogeneous
    % transformation matrix


    p = g(1:3,4);
end