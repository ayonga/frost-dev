function [contact, fric_coef, geometry] = RightSoleInside(robot)
  
    param = sys.GetExtraParams();
    
    
    r_foot_frame = robot.Joints(getJointIndices(robot, 'r_leg_akx'));
    contact = CoordinateFrame(...
        'Name','RightSole',...
        'Reference',r_foot_frame,...
        'Offset',[0, param.wf/2, param.hf],...
        'R',[0,0,0]... % z-axis is the normal axis, so no rotation required
        );
    
    fric_coef.mu = param.mu;
    fric_coef.gamma = param.gamma;
    
    
    geometry.la = param.wf/2;
    geometry.lb = param.wf/2;
    geometry.La = param.lt;
    geometry.Lb = param.lh;
end