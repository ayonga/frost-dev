function boxes = getGrillAndTableSpecs()
    grill_left_y = 0.16; % here left means left side of the robot
    grill_right_y = -0.64; % right side of the robot
    grill_near_x = 0.54; % closest x position of the grill
    grill_far_x = 0.9; % farthest x position of the grill
    grill_height = 0.085; % height of the grill w.r.t. base of robot
    table_left_x = -0.4; % left side of the robot
    table_right_x = 0.58; % right side of the robot
    table_height = 0.11; % height of the table w.r.t. base of robot
    table_near_y = 0.13; % closest x position of the grill
    table_far_y = 0.9; % farthest x position of the grill
    table_max_height = 0.7; % maximum height w.r.t. base of fanuc
    grill_max_height = 0.6; % maximum height w.r.t. base of fanuc


    boxes.table_box.p_min = [table_left_x, table_near_y, table_height];
    boxes.table_box.p_max = [table_right_x, table_far_y, table_max_height];

    boxes.grill_box.p_min = [grill_near_x, grill_right_y, grill_height];
    boxes.grill_box.p_max = [grill_far_x, grill_left_y, grill_max_height];
    
    if table_near_y > grill_left_y || grill_near_x > table_right_x
        error('It is preferred to have an overlap of the grill and table boxes. Change table grill specifications accordingly.');
    end
end