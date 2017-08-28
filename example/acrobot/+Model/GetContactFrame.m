function [frame, fric_coef, geom] = GetContactFrame(robot)
    %GET_CONTACT_FRAME Summary of this function goes here
    %   Detailed explanation goes here
    
    lt = 0;
    lh = 0.2;
    
    frame = Model.PlanarPlaneContact('Name','foot',...
        'Reference',robot.Joints(3),...
        'R',[0,0,0],...
        'Offset',[0,0,0],...
        'Type','PlanarContactWithFriction');
    
    fric_coef.mu = 0.9;
    fric_coef.gamma = 100;
    geom.la = 0;
    geom.lb = 0;
    geom.La = lt;
    geom.Lb = lh;
end

