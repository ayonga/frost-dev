function pre_process(model, t0, x0)

joint_torque = model.Inputs.torque;
Params = joint_torque.Params;
Params.p = Params.p + t0;
joint_torque.Params = Params;

end

