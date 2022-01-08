function R = rigid_orientation(g)
    % extract the rigid orientation from the homogeneous
    % transformation matrix
    
    R = g(1:3,1:3);
    
end