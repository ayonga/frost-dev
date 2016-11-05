function model = parseURDF(obj, urdf_file)
% This function parse the ROS URDF file into a matlab struct
%
% @todo This function need to be implemented soon 
%
% @note At this moment, this parser only support the 'link' and 'joint'
% elements in the URDF file. More options are coming soon ...
%
% Parameters:
% urdf_file: the URDF file full path @type char
% 
% Return values:
% robot: a matlab struct that contains parsed robot parameters from the
% URDF file. @type struct

urdf = xmlread(urdf_file);

xml_robot = urdf.getElementsByTagName('robot').item(0);
assert(~isempty(xml_robot),['The provided URDF file does not contains ',...
    'the proper robot element. Please provide the correct file.']);

% extract rigid links
xml_links = xml_robot.getElementsByTagName('link');

num_links = xml_links.getLength();
links = struct();
index = 0;
for i=0:num_links-1
    xml_link = xml_links.item(i);
    if xml_link.hasChildNodes
    
        links(index+1).name = char(xml_link.getAttribute('name'));
        inertial = xml_link.getElementsByTagName('inertial').item(0);
        origin = inertial.getElementsByTagName('origin').item(0);
        mass   = inertial.getElementsByTagName('mass').item(0);
        inertia   = inertial.getElementsByTagName('inertia').item(0);
        
        
        ixx = str2double(inertia.getAttribute('ixx'));
        ixy = str2double(inertia.getAttribute('ixy'));
        ixz = str2double(inertia.getAttribute('ixz'));
        iyy = str2double(inertia.getAttribute('iyy'));
        iyz = str2double(inertia.getAttribute('iyz'));
        izz = str2double(inertia.getAttribute('izz'));
        
        links(index+1).mass = str2double(mass.getAttribute('value'));
        links(index+1).origin.xyz = str2num(origin.getAttribute('xyz')); %#ok<*ST2NM>
        links(index+1).origin.rpy = str2num(origin.getAttribute('rpy'));
        links(index+1).inertia = [ixx,ixy,ixz; ixy,iyy,iyz; ixz, iyz, izz];
        
        index = index + 1;
    end

end



% extract joints
xml_joints = xml_robot.getElementsByTagName('joint');
joints = struct();
num_joints = xml_joints.getLength();
index = 0;
for i=0:num_joints-1
    xml_joint = xml_joints.item(i);
    
    if xml_joint.hasChildNodes
        joints(index+1).name = char(xml_joint.getAttribute('name'));
        joints(index+1).type = char(xml_joint.getAttribute('type'));
        
        
        origin = xml_joint.getElementsByTagName('origin').item(0);
        axis = xml_joint.getElementsByTagName('axis').item(0);
        parent = xml_joint.getElementsByTagName('parent').item(0);
        child = xml_joint.getElementsByTagName('child').item(0);
        limit = xml_joint.getElementsByTagName('limit').item(0);
        
        joints(index+1).origin.xyz = str2num(origin.getAttribute('xyz'));
        joints(index+1).origin.rpy = str2num(origin.getAttribute('rpy'));
        joints(index+1).axis = str2num(axis.getAttribute('xyz'));
        joints(index+1).parent = char(parent.getAttribute('link'));
        joints(index+1).child  = char(child.getAttribute('link'));
        joints(index+1).limit.effort = str2double(limit.getAttribute('effort'));
        joints(index+1).limit.lower = str2double(limit.getAttribute('lower'));
        joints(index+1).limit.upper = str2double(limit.getAttribute('upper'));
        joints(index+1).limit.velocity = str2double(limit.getAttribute('velocity'));
        
        index = index + 1;
    end

end

    

model = struct();
model.name   = xml_robot.getAttribute('name');
model.joints = joints;
model.links  = links;





end

