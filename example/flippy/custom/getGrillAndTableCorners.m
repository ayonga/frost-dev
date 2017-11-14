function corners = getGrillAndTableCorners()
    corners.grill.far_left =   [0.85 0.12 0.25];
    corners.grill.far_right =  [0.85 -0.56 0.25];
    corners.grill.near_left =  [0.55 0.14 0.25];
    corners.grill.near_right = [0.55 -0.56 0.25];
    
    corners.table.far_left =   [-0.2  0.8 0.25];
    corners.table.far_right =  [0.4   0.8 0.25];
    corners.table.near_left =  [-0.2  0.6 0.25];
    corners.table.near_right = [0.4   0.6 0.25];
end