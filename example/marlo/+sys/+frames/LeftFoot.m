function [contact, fric_coef] = LeftFoot(robot)
  
    
    
    l_knee_frame = robot.Joints(getJointIndices(robot, 'fourBarBLeft'));
    contact = ContactFrame(...
        'Name','LeftFoot',...
        'Reference',l_knee_frame,...
        'Offset',[0, 0, 0.6],...
        'R',[0,0,0],... % z-axis is the normal axis, so no rotation required
        'Type','PointContactWithFriction'...
        );
    
    
    
    fric_coef.mu = 0.6;
    fric_coef.gamma = 100;
end