function obj = addChildJoints(obj, joint)
    % set the reference frame
    %
    % Parameters:
    % ref: the reference frame object @type CoordinateFrame
    
    assert(isa(joint,'RigidJoint'),...
        'The input must be a RigidJoint object.');
    if ~isempty(obj.ChildJoints)
        for i=1:numel(obj.ChildJoints)
            if ~strcmp(joint.Name, obj.ChildJoints(i).Name)
                obj.ChildJoints = [obj.ChildJoints,joint];
            end
        end
    else
        obj.ChildJoints = joint;
    end
    
end