function [base_dofs] = GetCustomBase()
    base_dofs(6) = struct(); % 6-DOF base coordinates
    [base_dofs(1:6).Name] = deal('BasePosX','BasePosY','BasePosZ','BaseRotZ','BaseRotY','BaseRotX'); 
    
    % the type of the base dofs
    [base_dofs(1:3).Type] = deal('prismatic'); % the first three are prismatic joints
    [base_dofs(4:6).Type] = deal('revolute');  % the last three are revolute joints
    
    % the origin are all zeros
    [base_dofs.Offset] = deal([0,0,0]);
    [base_dofs.R] = deal([0,0,0]);
    
    % the axis of the base dofs
    [base_dofs(1:3).Axis] = deal([1,0,0],[0,1,0],[0,0,1]);
    [base_dofs(4:6).Axis] = deal([0,0,1],[0,1,0],[1,0,0]);
    
    % the parent link of the base dofs
    [base_dofs.Parent] =  deal('Origin', 'BasePosX','BasePosY','BasePosZ','BaseRotZ','BaseRotY'); 
    
    % the child link of the base dofs
    [base_dofs.Child] = deal('BasePosX','BasePosY','BasePosZ','BaseRotZ','BaseRotY','');
    
    % the limitation of the base dofs
    [limit(1:6).lower] = deal(-10, -1, 0.7, -0.1, -0.5, -0.1);
    [limit(1:6).upper] = deal(10, 1, 0.9, 0.1, 0.5, 0.1);
    [limit(1:6).velocity] = deal(1, 0.5, 0.5, 0.5, 0.5, 0.5);
    [limit(1:6).effort] = deal(0);
    for i=1:6
        base_dofs(i).Limit = limit(i);
    end
end
