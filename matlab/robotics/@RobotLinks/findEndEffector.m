function [terminals,terminal_links] = findEndEffector(obj, joints)
    % Determines the end effector link of an array of rigid joints
    %
    % The end-effector link is the link that is not a parent link of any joints.
    %
    % Parameters:
    % joints: an array of rigid joints @type RigidJoint
    %
    % @note if 'joints' argument is not provided, it uses the default
    % 'Joints' property of the object.
    %
    % Return values:
    % terminals: the indices of the end effector coordinates @type rowvec
    % terminal_links: the indices of the end effector links @type cell
    if nargin < 2
        joints = obj.Joints;
    end
    
    c_indices = str_indices({joints.Child},{joints.Parent},'UniformOutput',false);
    terminals = find(cellfun(@isempty,c_indices));
    terminal_links = joints(terminals).Child;
    if isempty(terminals)
        error('Unable to find any end-effector link.');
    end
        
end