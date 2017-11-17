function [contact, fric_coef, geometry] = LeftSoleInside(robot)
  
    param = sys.GetExtraParams();
    
    
    l_foot_frame = robot.Joints(getJointIndices(robot, 'l_leg_akx'));
    contact = CoordinateFrame(...
        'Name','LeftSole',...
        'Reference',l_foot_frame,...
        'Offset',[0, -param.wf/2, param.hf],...
        'R',[0,0,0]... % z-axis is the normal axis, so no rotation required
        );
    
    fric_coef.mu = param.mu;
    fric_coef.gamma = param.gamma;
    
        
    
    geometry.la = param.wf/2;
    geometry.lb = param.wf/2;
    geometry.La = param.lt;
    geometry.Lb = param.lh;
end