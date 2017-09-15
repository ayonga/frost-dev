f_push = CoordinateFrame('Name','push',...
    'Reference',robot.Joints(end),...
    'Offset',[0,0,0.05],...
    'R',[0,0,0]);

p_push_sym = getCartesianPosition(robot,f_push);
J_push_sym = getBodyJacobian(robot,f_push);
p_push_sym_fun = SymFunction(['pos_push_',robot.Name],p_push_sym([1,3]),{robot.States.x});
J_push_sym_fun = SymFunction(['jac_push_',robot.Name],transpose(J_push_sym([1,3],:)),{robot.States.x});

p_push_sym_fun.export(export_path);
J_push_sym_fun.export(export_path);