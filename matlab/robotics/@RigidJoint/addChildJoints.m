function obj = addChildJoints(obj, joint, joint_index)
    % set the reference frame
    %
    % Parameters:
    % ref: the reference frame object @type CoordinateFrame
    
    assert(isa(joint,'RigidJoint'),...
        'The input must be a RigidJoint object.');
    if ~isempty(obj.ChildJoints)
        
        child_joint_names = {obj.ChildJoints.Name};
        j_idx = str_index(joint.Name, child_joint_names);
        if isempty(j_idx)
            obj.ChildJoints = [obj.ChildJoints,joint];
            obj.ChildJointIndices = [obj.ChildJointIndices,joint_index];
        end
    else
        obj.ChildJoints = joint;
        obj.ChildJointIndices = joint_index;
    end
    
end